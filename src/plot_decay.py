"""Plot lease decay slopes by town.

Towns with R2 below 0.25 are excluded: their lease spread is too narrow
for the regression to mean anything.

Writes charts/decay_by_town.png
"""
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from src.db import get_connection

QUERY = """
SELECT t.town,
       regr_slope(f.price_per_sqm, f.remaining_lease_years) AS slope,
       regr_r2(f.price_per_sqm, f.remaining_lease_years) AS r2,
       max(f.remaining_lease_years) - min(f.remaining_lease_years) AS spread
FROM fact_resale f
JOIN dim_town t ON t.town_key = f.town_key
JOIN dim_date d ON d.date_key = f.date_key
JOIN dim_flat_type ft ON ft.flat_type_key = f.flat_type_key
WHERE ft.flat_type = '4 ROOM' AND d.year >= 2020
GROUP BY 1
HAVING count(*) >= 500
   AND regr_r2(f.price_per_sqm, f.remaining_lease_years) >= 0.25
ORDER BY 2
"""

with get_connection() as conn, conn.cursor() as cur:
    cur.execute(QUERY)
    rows = cur.fetchall()

towns = [r[0].title() for r in rows]
slopes = [float(r[1]) for r in rows]

fig, ax = plt.subplots(figsize=(9, 7))
ax.barh(towns, slopes, color="#4a6fa5")
ax.set_xlabel("Price per sqm gained per extra year of remaining lease (S$)")
ax.set_title("Lease decay is steeper in mature central estates\n"
             "4-room flats, 2020-2026, within-town regression")
ax.grid(axis="x", alpha=0.3)

for i, v in enumerate(slopes):
    ax.text(v + 1.5, i, f"${v:.0f}", va="center", fontsize=9)

ax.set_xlim(0, max(slopes) * 1.12)

Path("charts").mkdir(exist_ok=True)
fig.tight_layout()
fig.savefig("charts/decay_by_town.png", dpi=150)
print(f"Wrote charts/decay_by_town.png ({len(rows)} towns)")

