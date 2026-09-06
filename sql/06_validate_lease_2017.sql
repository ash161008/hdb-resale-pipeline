-- Parse "61 years 04 months" into a numeric year value, then compare
-- against the derived whole-year figure.
WITH parsed AS (
    SELECT
        remaining_lease_years,
        (regexp_match(remaining_lease_raw, '^([0-9]+) years?'))[1]::int
          + COALESCE((regexp_match(remaining_lease_raw, '([0-9]+) months?'))[1]::int, 0) / 12.0
          AS hdb_years
    FROM clean_resale
    WHERE source_file = 'resale_2017_onwards.csv'
)
SELECT
    round(min(remaining_lease_years - hdb_years), 3) AS min_diff,
    round(max(remaining_lease_years - hdb_years), 3) AS max_diff,
    round(avg(remaining_lease_years - hdb_years), 3) AS avg_diff,
    count(*) FILTER (WHERE abs(remaining_lease_years - hdb_years) > 1) AS beyond_one_year,
    count(*) AS total
FROM parsed;
