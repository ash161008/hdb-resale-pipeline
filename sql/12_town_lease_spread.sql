-- Which towns have enough lease-year spread to support within-town comparison?
SELECT t.town,
       count(*) AS sales,
       min(f.remaining_lease_years) AS min_lease,
       max(f.remaining_lease_years) AS max_lease,
       max(f.remaining_lease_years) - min(f.remaining_lease_years) AS spread,
       count(DISTINCT (f.remaining_lease_years / 10) * 10) AS decades
FROM fact_resale f
JOIN dim_town t ON t.town_key = f.town_key
JOIN dim_date d ON d.date_key = f.date_key
JOIN dim_flat_type ft ON ft.flat_type_key = f.flat_type_key
WHERE ft.flat_type = '4 ROOM' AND d.year >= 2020
GROUP BY 1
ORDER BY 6 DESC, 5 DESC;
