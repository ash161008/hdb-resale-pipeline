"""Database connection for the HDB resale pipeline."""
import os
import psycopg2

def get_connection():
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "hdb"),
        user=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", "devpassword"),
    )

def query_one(sql, params=None):
    """Run a query and return the first column of the first row."""
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute(sql, params)
        return cur.fetchone()[0]
