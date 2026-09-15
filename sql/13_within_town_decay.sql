-- Lease decay within single towns, 4 ROOM, 2020+.
-- Location held constant by comparing only inside each town.
SELECT t.town,
       (f.remaining_lease_years / 10) * 10 AS lease_decade,
       count(*) AS sales,
       round(avg(f.price_per_sqm)) AS avg_psm
FROM fact_resale f
JOIN dim_town t ON t.town_key = f.town_key
JOIN dim_date d ON d.date_key = f.date_key
JOIN dim_flat_type ft ON ft.flat_type_key = f.flat_type_key
WHERE ft.flat_type = '4 ROOM'
  AND d.year >= 2020
  AND t.town IN ('WOODLANDS','JURONG WEST','HOUGANG','BEDOK','ANG MO KIO','TOA PAYOH')
GROUP BY 1,2
HAVING count(*) >= 50
ORDER BY 1,2;
