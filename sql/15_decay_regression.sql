-- Least-squares slope of price per sqm against remaining lease years,
-- computed within each town so location is held constant.
SELECT t.town,
       count(*) AS sales,
       round(regr_slope(f.price_per_sqm, f.remaining_lease_years)::numeric, 1) AS psm_per_lease_year,
       round(regr_r2(f.price_per_sqm, f.remaining_lease_years)::numeric, 3) AS r2,
       round(avg(f.price_per_sqm)) AS avg_psm
FROM fact_resale f
JOIN dim_town t ON t.town_key = f.town_key
JOIN dim_date d ON d.date_key = f.date_key
JOIN dim_flat_type ft ON ft.flat_type_key = f.flat_type_key
WHERE ft.flat_type = '4 ROOM' AND d.year >= 2020
GROUP BY 1
HAVING count(*) >= 500
ORDER BY 3 DESC;
