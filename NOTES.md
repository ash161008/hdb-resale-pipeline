# Notes

## Source data
Five CSVs from data.gov.sg collection 189, downloaded 6 Sep 2026.
986,090 rows total. Coverage 1990-01 to 2026-09, contiguous, no overlaps.

## Schema differences across files
- 1990-1999, 2000-2012, 2012-2014: 10 columns, no remaining_lease
- 2015-2016: 11 columns, remaining_lease as bare integer years (e.g. 70)
- 2017-onwards: 11 columns, remaining_lease as text (e.g. "61 years 04 months")

## date_basis
Files up to 2012-02 use approval date; 2012-03 onwards use registration date.
HDB changed convention. Not convertible. Recorded per row in date_basis column.

## Decisions
- Raw layer is all TEXT. Type conversion happens downstream so bad rows can be
  counted rather than blocking the load.
- Deriving remaining lease from lease_commence_date for all rows rather than
  parsing HDB's column, which has three formats and covers only 28% of rows.
  Cost: whole years, not months. Validate against HDB's value for 2017+ rows.

## Known limits
- 2026-09 is the current month and likely partial. Exclude from trend analysis.
- flat_model casing differs across eras (IMPROVED vs Improved). Needs normalising.

## Validation of derived remaining_lease_years
Compared against HDB's own column for resale_2015_2016.csv (37,153 rows):
  diff -1:     20 rows (0.05%)
  diff  0: 19,070 rows (51.3%)
  diff +1: 18,063 rows (48.6%)
Bounded at +/- 1 year, no outliers.
Cause: we subtract calendar years; HDB counts from the actual lease commencement
date. The 0/+1 split reflects whether the sale falls before or after the lease
anniversary. The 20 negative rows are almost all January sales, where the
calendar year has advanced but the anniversary has not.
Accepted: whole-year resolution is sufficient for lease-decay curves measured
in years. Documented rather than corrected, since commencement dates are not
published.

## flat_model casing
13 of 21 models split across two spellings. MODEL A understated by 70,381 rows.
Verified spellings never coexist in one source file: MODEL A appears only in
1990-1999, Model A only in the four later files. upper() is therefore safe.

## storey_range
8 five-storey buckets confined to 2012-03 to 2012-05 (6,838 rows, 0.7%).
All other data uses 3-storey buckets. Kept in the table; storey_range_3 is NULL
for these rows so they drop out of storey-based analysis without being deleted.

## Type conversion
Zero rows fail conversion on month, resale_price, floor_area_sqm or
lease_commence_date. No nulls in key columns. Source data is clean.

## 2017+ validation and a source data error
Parsed HDB's text remaining_lease ("61 years 04 months") and compared against
the derived figure for all 239,887 rows in resale_2017_onwards.csv.
135 rows fall between -1.17 and -1.08 years: the same anniversary effect,
measured against month precision rather than rounded years.
One row is a genuine source error: block 37 TEBAN GDNS RD, sale 2025-01,
lease_commence_date recorded as 1981. The other 20 recorded sales of that block
all say 1966, and the adjacent 2025-06 sale is consistent with a 99-year lease
from 1966. HDB's own remaining_lease on the bad row (40 years 01 month) also
implies 1966.
Left uncorrected. Source data is reproduced as published; the discrepancy is
documented rather than silently edited.

Overall: derived remaining_lease_years agrees with HDB's published value to
within one year on all 277,040 rows where comparison is possible, with one
exception traced to a source error.

## Building-level conflicts (address key investigation)
Only 3 addresses in ~10,000 have more than one lease_commence_year.
No address spans more than one town, so (block, street_name) is a viable key
and town need not be part of it.

  21 TEBAN GDNS RD    1978 (54 sales, 1990-01 to 1999-10)
                      2013 (78 sales, 2016-08 to 2026-08)
                      17-year sales gap -> redevelopment, two physical buildings

  37 TEBAN GDNS RD    1966 (20 sales) / 1981 (1 sale, 2025-01)
                      single-row typo, confirmed against adjacent 2025-06 sale

  114 JURONG EAST ST 13  1981 (10 sales, to 2014-10)
                         1982 (3 sales, from 2015-04)
                         6-month gap, 1-year delta, and the change spans two
                         source files on each side -> HDB records correction,
                         not a rebuild

Population of 3 is small enough to handle case by case rather than by rule.
Decision pending on each.

## Resolution of the three conflicts
21 TEBAN GDNS RD  -> two dimension rows (1978, 2013). Redevelopment: 17-year
                     sales gap, 35-year lease jump. Genuinely two buildings.
37 TEBAN GDNS RD  -> one row, 1966. Single-row typo; HDB's own remaining_lease
                     on that row (40 years 01 month) contradicts its 1981 and
                     confirms 1966.
114 JURONG EAST ST 13 -> one row, 1982. HDB records correction, not a typo.
                     Their remaining_lease agrees with 1982 in all three
                     post-2015 sales (66 in 2015, 65 in 2016, 55y11m in
                     2025-12). Majority vote would have given 1981 and been
                     wrong; the newer value is the corrected one.

## Star schema
dim_building (10,005 rows / 10,004 addresses), dim_town (27), dim_flat_type (8),
dim_flat_model (21), dim_storey (25), dim_date (441 months, no gaps).
fact_resale: 986,090 rows, exact match to source, foreign keys to all six.

dim_building uses surrogate keys with a validity range (Type 2 SCD), which is
what lets block 21 TEBAN GDNS RD carry two rows for the same address. The
fact-to-building join matches on address AND sale date within the range.

fact_resale recomputes remaining_lease_years from dim_building.lease_commence_year
rather than the raw value, so the three resolved conflicts are corrected
structurally. Verified: block 37 TEBAN GDNS RD 2025-01 shows 40 in the fact
table vs 55 in the raw data.
