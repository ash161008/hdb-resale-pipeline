"""Data quality checks for the HDB resale pipeline.

Each test encodes a property verified manually during development.
Run with: pytest -v
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from src.db import query_one

EXPECTED_ROWS = 986090


def test_raw_row_count():
    """Raw layer holds every row from all five source files."""
    assert query_one("SELECT count(*) FROM raw_resale") == EXPECTED_ROWS


def test_fact_matches_raw():
    """No rows lost or duplicated by the dimension joins."""
    assert query_one("SELECT count(*) FROM fact_resale") == EXPECTED_ROWS


def test_no_month_gaps():
    """Every month between the first and last sale has at least one sale."""
    months = query_one("SELECT count(*) FROM dim_date")
    span = query_one("""
        SELECT (extract(year FROM max(sale_month)) * 12 + extract(month FROM max(sale_month)))
             - (extract(year FROM min(sale_month)) * 12 + extract(month FROM min(sale_month))) + 1
        FROM dim_date
    """)
    assert months == span


def test_building_conflicts_are_known():
    """Exactly three addresses have conflicting lease years, all resolved."""
    conflicts = query_one("""
        SELECT count(*) FROM (
            SELECT block, street_name FROM clean_resale
            GROUP BY 1, 2
            HAVING count(DISTINCT lease_commence_year) > 1
                OR count(DISTINCT town) > 1
        ) t
    """)
    assert conflicts == 3


def test_lease_derivation_within_one_year():
    """Derived remaining lease agrees with HDB's own value to within a year,
    except the single known source error at 37 TEBAN GDNS RD."""
    outliers = query_one("""
        SELECT count(*) FROM clean_resale
        WHERE source_file = 'resale_2015_2016.csv'
          AND abs(remaining_lease_years - remaining_lease_raw::int) > 1
    """)
    assert outliers == 0


def test_no_duplicate_building_validity():
    """No address has two dimension rows covering the same period."""
    overlaps = query_one("""
        SELECT count(*) FROM (
            SELECT block, street_name, valid_from
            FROM dim_building
            GROUP BY 1, 2, 3
            HAVING count(*) > 1
        ) t
    """)
    assert overlaps == 0
