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
