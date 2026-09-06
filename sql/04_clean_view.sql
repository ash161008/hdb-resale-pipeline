DROP VIEW IF EXISTS clean_resale;

CREATE VIEW clean_resale AS
SELECT
    id,
    to_date(month, 'YYYY-MM')                   AS sale_month,
    town,
    flat_type,
    block,
    street_name,
    storey_range,
    CASE WHEN storey_range ~ '^(01 TO 05|06 TO 10|11 TO 15|16 TO 20|21 TO 25|26 TO 30|31 TO 35|36 TO 40)$'
         THEN NULL ELSE storey_range END        AS storey_range_3,
    floor_area_sqm::numeric                     AS floor_area_sqm,
    upper(flat_model)                           AS flat_model,
    lease_commence_date::int                    AS lease_commence_year,
    remaining_lease                             AS remaining_lease_raw,
    99 - (extract(year FROM to_date(month, 'YYYY-MM'))::int - lease_commence_date::int)
                                                AS remaining_lease_years,
    resale_price::numeric                       AS resale_price,
    resale_price::numeric / floor_area_sqm::numeric AS price_per_sqm,
    source_file,
    date_basis
FROM raw_resale;
