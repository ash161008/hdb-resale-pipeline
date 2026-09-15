-- Step change in price per sqm between adjacent lease decades, within town.
WITH cells AS (
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
)
SELECT town, lease_decade, sales, avg_psm,
       LAG(avg_psm) OVER w AS prev_psm,
       avg_psm - LAG(avg_psm) OVER w AS step,
       round(100.0 * (avg_psm - LAG(avg_psm) OVER w) / LAG(avg_psm) OVER w, 1) AS pct_step
FROM cells
WINDOW w AS (PARTITION BY town ORDER BY lease_decade)
ORDER BY town, lease_decade;

