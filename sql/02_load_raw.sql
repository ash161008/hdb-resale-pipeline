-- Load raw layer: five CSVs from data.gov.sg collection 189
-- Downloaded 6 Sep 2026. Run in order.
-- The \copy lines need a shell pipe and won't run from this file.
-- Pattern:
--   cat data/raw/<file>.csv | docker exec -i hdb-postgres \
--     psql -U postgres -d hdb -c "\copy <staging> FROM STDIN WITH (FORMAT csv, HEADER true)"

CREATE TABLE stg_resale_10col (
    month TEXT, town TEXT, flat_type TEXT, block TEXT, street_name TEXT,
    storey_range TEXT, floor_area_sqm TEXT, flat_model TEXT,
    lease_commence_date TEXT, resale_price TEXT
);

CREATE TABLE stg_resale_11col (
    month TEXT, town TEXT, flat_type TEXT, block TEXT, street_name TEXT,
    storey_range TEXT, floor_area_sqm TEXT, flat_model TEXT,
    lease_commence_date TEXT, remaining_lease TEXT, resale_price TEXT
);

-- For each 10-column file: TRUNCATE stg_resale_10col, \copy it in, then:
INSERT INTO raw_resale (month, town, flat_type, block, street_name, storey_range,
    floor_area_sqm, flat_model, lease_commence_date, resale_price, source_file, date_basis)
SELECT month, town, flat_type, block, street_name, storey_range,
    floor_area_sqm, flat_model, lease_commence_date, resale_price,
    'resale_1990_1999.csv', 'approval'
FROM stg_resale_10col;

-- Repeat with: resale_2000_2012.csv / approval
--              resale_2012_2014.csv / registration

-- For each 11-column file: TRUNCATE stg_resale_11col, \copy it in, then:
INSERT INTO raw_resale (month, town, flat_type, block, street_name, storey_range,
    floor_area_sqm, flat_model, lease_commence_date, remaining_lease, resale_price,
    source_file, date_basis)
SELECT month, town, flat_type, block, street_name, storey_range,
    floor_area_sqm, flat_model, lease_commence_date, remaining_lease, resale_price,
    'resale_2015_2016.csv', 'registration'
FROM stg_resale_11col;

-- Repeat with: resale_2017_onwards.csv / registration

-- Verify:
-- SELECT source_file, date_basis, count(*), min(month), max(month),
--        count(remaining_lease) FROM raw_resale GROUP BY 1,2;
-- Expect 986,090 rows total, coverage 1990-01 to 2026-09.
