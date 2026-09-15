DROP TABLE IF EXISTS fact_resale;

CREATE TABLE fact_resale (
    resale_id        BIGINT PRIMARY KEY,
    date_key         INT      NOT NULL REFERENCES dim_date(date_key),
    building_key     BIGINT   NOT NULL REFERENCES dim_building(building_key),
    town_key         SMALLINT NOT NULL REFERENCES dim_town(town_key),
    flat_type_key    SMALLINT NOT NULL REFERENCES dim_flat_type(flat_type_key),
    flat_model_key   SMALLINT NOT NULL REFERENCES dim_flat_model(flat_model_key),
    storey_key       SMALLINT NOT NULL REFERENCES dim_storey(storey_key),
    floor_area_sqm   NUMERIC  NOT NULL,
    resale_price     NUMERIC  NOT NULL,
    price_per_sqm    NUMERIC  NOT NULL,
    remaining_lease_years INT NOT NULL,
    date_basis       TEXT     NOT NULL
);

INSERT INTO fact_resale
SELECT
    c.id,
    d.date_key,
    b.building_key,
    t.town_key,
    ft.flat_type_key,
    fm.flat_model_key,
    s.storey_key,
    c.floor_area_sqm,
    c.resale_price,
    c.price_per_sqm,
    99 - (extract(year FROM c.sale_month)::int - b.lease_commence_year),
    c.date_basis
FROM clean_resale c
JOIN dim_date       d  ON d.sale_month  = c.sale_month
JOIN dim_building   b  ON b.block       = c.block
                      AND b.street_name = c.street_name
                      AND c.sale_month >= b.valid_from
                      AND c.sale_month <  b.valid_to
JOIN dim_town       t  ON t.town        = c.town
JOIN dim_flat_type  ft ON ft.flat_type  = c.flat_type
JOIN dim_flat_model fm ON fm.flat_model = c.flat_model
JOIN dim_storey     s  ON s.storey_range = c.storey_range;
