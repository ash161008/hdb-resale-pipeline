DROP TABLE IF EXISTS dim_building;

CREATE TABLE dim_building (
    building_key        BIGSERIAL PRIMARY KEY,
    block               TEXT NOT NULL,
    street_name         TEXT NOT NULL,
    town                TEXT NOT NULL,
    lease_commence_year INT  NOT NULL,
    valid_from          DATE NOT NULL,
    valid_to            DATE NOT NULL,
    is_exception        BOOLEAN NOT NULL,
    UNIQUE (block, street_name, valid_from)
);

INSERT INTO dim_building (block, street_name, town, lease_commence_year,
                          valid_from, valid_to, is_exception)
-- Buildings with a manually resolved conflict: take the exception rows.
SELECT e.block, e.street_name,
       (SELECT DISTINCT c.town FROM clean_resale c
         WHERE c.block = e.block AND c.street_name = e.street_name),
       e.lease_commence_year, e.valid_from, e.valid_to, true
FROM building_exceptions e

UNION ALL

-- Everything else: one row per address, spanning all time.
SELECT block, street_name, min(town), min(lease_commence_year),
       DATE '1900-01-01', DATE '9999-12-31', false
FROM clean_resale
WHERE (block, street_name) NOT IN (
    SELECT block, street_name FROM building_exceptions
)
GROUP BY block, street_name;
