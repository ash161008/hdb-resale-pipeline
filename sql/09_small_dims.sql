DROP TABLE IF EXISTS dim_town CASCADE;
DROP TABLE IF EXISTS dim_flat_type CASCADE;
DROP TABLE IF EXISTS dim_flat_model CASCADE;
DROP TABLE IF EXISTS dim_storey CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

CREATE TABLE dim_town (
    town_key   SMALLSERIAL PRIMARY KEY,
    town       TEXT NOT NULL UNIQUE,
    is_mature  BOOLEAN
);
INSERT INTO dim_town (town) SELECT DISTINCT town FROM clean_resale ORDER BY 1;

CREATE TABLE dim_flat_type (
    flat_type_key SMALLSERIAL PRIMARY KEY,
    flat_type     TEXT NOT NULL UNIQUE
);
INSERT INTO dim_flat_type (flat_type) SELECT DISTINCT flat_type FROM clean_resale ORDER BY 1;

CREATE TABLE dim_flat_model (
    flat_model_key SMALLSERIAL PRIMARY KEY,
    flat_model     TEXT NOT NULL UNIQUE
);
INSERT INTO dim_flat_model (flat_model) SELECT DISTINCT flat_model FROM clean_resale ORDER BY 1;

CREATE TABLE dim_storey (
    storey_key    SMALLSERIAL PRIMARY KEY,
    storey_range  TEXT NOT NULL UNIQUE,
    storey_low    INT  NOT NULL,
    storey_high   INT  NOT NULL,
    is_three_band BOOLEAN NOT NULL
);
INSERT INTO dim_storey (storey_range, storey_low, storey_high, is_three_band)
SELECT DISTINCT storey_range,
       split_part(storey_range, ' TO ', 1)::int,
       split_part(storey_range, ' TO ', 2)::int,
       (split_part(storey_range, ' TO ', 2)::int - split_part(storey_range, ' TO ', 1)::int) = 2
FROM clean_resale ORDER BY 2;

CREATE TABLE dim_date (
    date_key   INT PRIMARY KEY,
    sale_month DATE NOT NULL UNIQUE,
    year       INT  NOT NULL,
    month_num  INT  NOT NULL,
    quarter    INT  NOT NULL
);
INSERT INTO dim_date (date_key, sale_month, year, month_num, quarter)
SELECT DISTINCT
       extract(year FROM sale_month)::int * 100 + extract(month FROM sale_month)::int,
       sale_month,
       extract(year FROM sale_month)::int,
       extract(month FROM sale_month)::int,
       extract(quarter FROM sale_month)::int
FROM clean_resale ORDER BY 2;
