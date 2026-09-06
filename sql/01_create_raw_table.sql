CREATE TABLE raw_resale (
    id              BIGSERIAL PRIMARY KEY,
    month           TEXT,
    town            TEXT,
    flat_type       TEXT,
    block           TEXT,
    street_name     TEXT,
    storey_range    TEXT,
    floor_area_sqm  TEXT,
    flat_model      TEXT,
    lease_commence_date TEXT,
    remaining_lease TEXT,
    resale_price    TEXT,
    source_file     TEXT NOT NULL,
    date_basis      TEXT NOT NULL,
    loaded_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
