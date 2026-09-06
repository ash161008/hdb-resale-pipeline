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
