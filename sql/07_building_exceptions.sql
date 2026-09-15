-- Manually resolved building-level conflicts.
-- Only 3 addresses in ~10,000 have more than one lease_commence_year,
-- so each was investigated individually rather than by rule.
-- See NOTES.md for the evidence behind each decision.

DROP TABLE IF EXISTS building_exceptions;

CREATE TABLE building_exceptions (
    block           TEXT NOT NULL,
    street_name     TEXT NOT NULL,
    lease_commence_year INT NOT NULL,
    valid_from      DATE NOT NULL,
    valid_to        DATE NOT NULL,
    reason          TEXT NOT NULL
);

INSERT INTO building_exceptions VALUES
('21',  'TEBAN GDNS RD',     1978, '1900-01-01', '2013-01-01',
 'Redevelopment. 17-year sales gap (1999-10 to 2016-08), 35-year lease jump. Original building.'),
('21',  'TEBAN GDNS RD',     2013, '2013-01-01', '9999-12-31',
 'Redevelopment. Replacement building on same address.'),
('37',  'TEBAN GDNS RD',     1966, '1900-01-01', '9999-12-31',
 'Single-row typo (1981 on 2025-01 sale). HDB remaining_lease on that row implies 1966.'),
('114', 'JURONG EAST ST 13', 1982, '1900-01-01', '9999-12-31',
 'HDB records correction, not a typo. remaining_lease agrees with 1982 in all post-2015 sales.');
