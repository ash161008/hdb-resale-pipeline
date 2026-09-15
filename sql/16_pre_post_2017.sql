-- Did the lease slope steepen after the March 2017 statement that flats
-- revert to the state with no value? Compared in relative terms so the
-- post-2020 price boom does not masquerade as a steeper slope.
WITH periods AS (
    SELECT t.town,
           CASE WHEN d.year BETWEEN 2013 AND 2016 THEN 'pre'
                WHEN d.year BETWEEN 2018 AND 2021 THEN 'post' END AS period,
           f.price_per_sqm, f.remaining_lease_years
    FROM fact_resale f
    JOIN dim_town t ON t.town_key = f.town_key
    JOIN dim_date d ON d.date_key = f.date_key
    JOIN dim_flat_type ft ON ft.flat_type_key = f.flat_type_key
    WHERE ft.flat_type = '4 ROOM'
      AND d.year BETWEEN 2013 AND 2021
      AND d.year NOT IN (2017)
),
slopes AS (
    SELECT town, period,
           count(*) AS sales,
           regr_slope(price_per_sqm, remaining_lease_years) AS slope,
           regr_r2(price_per_sqm, remaining_lease_years) AS r2,
           avg(price_per_sqm) AS avg_psm
    FROM periods
    WHERE period IS NOT NULL
    GROUP BY 1,2
    HAVING count(*) >= 300 AND regr_r2(price_per_sqm, remaining_lease_years) >= 0.25
)
SELECT town,
       max(sales) FILTER (WHERE period='pre')  AS pre_n,
       max(sales) FILTER (WHERE period='post') AS post_n,
       round(max(slope) FILTER (WHERE period='pre')::numeric, 1)  AS pre_slope,
       round(max(slope) FILTER (WHERE period='post')::numeric, 1) AS post_slope,
       round(100 * max(slope / avg_psm) FILTER (WHERE period='pre')::numeric, 3)  AS pre_pct,
       round(100 * max(slope / avg_psm) FILTER (WHERE period='post')::numeric, 3) AS post_pct
FROM slopes
GROUP BY 1
HAVING count(*) = 2
ORDER BY 7 DESC;
