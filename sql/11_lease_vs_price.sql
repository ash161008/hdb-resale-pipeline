-- Price per sqm by remaining lease decade, within single sale years.
-- Restricted to 4 ROOM to hold flat type constant.
SELECT d.year,
       (f.remaining_lease_years / 10) * 10 AS lease_decade,
       count(*) AS sales,
       round(avg(f.price_per_sqm)) AS avg_psm
FROM fact_resale f
JOIN dim_date d ON d.date_key = f.date_key
JOIN dim_flat_type ft ON ft.flat_type_key = f.flat_type_key
WHERE ft.flat_type = '4 ROOM'
  AND d.year IN (2010, 2016, 2019, 2022, 2025)
GROUP BY 1, 2
HAVING count(*) >= 100
ORDER BY 1, 2;
