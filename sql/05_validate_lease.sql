-- Compare derived remaining_lease_years against HDB's own column
-- for the 2015-2016 file, where HDB gives bare integer years.
SELECT
    remaining_lease_years - remaining_lease_raw::int AS diff,
    count(*)
FROM clean_resale
WHERE source_file = 'resale_2015_2016.csv'
GROUP BY 1
ORDER BY 1;
