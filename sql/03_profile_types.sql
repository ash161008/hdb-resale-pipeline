SELECT
  count(*) FILTER (WHERE month !~ '^[0-9]{4}-[0-9]{2}$') AS bad_month,
  count(*) FILTER (WHERE resale_price !~ '^[0-9]+(\.[0-9]+)?$') AS bad_price,
  count(*) FILTER (WHERE floor_area_sqm !~ '^[0-9]+(\.[0-9]+)?$') AS bad_area,
  count(*) FILTER (WHERE lease_commence_date !~ '^[0-9]{4}$') AS bad_lease_year,
  count(*) FILTER (WHERE month IS NULL OR town IS NULL OR resale_price IS NULL) AS any_nulls
FROM raw_resale;
