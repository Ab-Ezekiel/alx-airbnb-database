# Performance Monitoring & Refinement

Purpose: show a small, repeatable workflow to monitor query performance, find bottlenecks, apply simple schema changes (indexes / small refactors), and record improvements.

> Keep this lightweight: pick 2–3 frequently used queries (search, availability check, booking listing), capture plans, change one thing, and measure again.

---

## 1 — Tools & commands (MySQL / MariaDB)
- `EXPLAIN FORMAT=JSON <query>;` — estimated execution plan (good, portable).
- `EXPLAIN ANALYZE <query>;` — actual runtime + plan (MySQL 8 / MariaDB recent) — runs the query.
- `SHOW PROFILE` / `SET profiling = 1;` — older, deprecated on some installs; prefer `EXPLAIN ANALYZE` or Performance Schema.
- `performance_schema` / slow query log — use for real production monitoring.
- `pt-query-digest` (Percona toolkit) — analyze slow query logs (optional).

---

## 2 — Simple monitoring workflow (repeatable)

1. **Choose query** to monitor (example names):
   - `Q1` = property search (filters + ORDER BY + LIMIT)
   - `Q2` = availability check for a property (date overlap)
   - `Q3` = bookings listing for a host (joins + pagination)

2. **Capture before plan & timings**
   ```sql
   -- estimated plan
   EXPLAIN FORMAT=JSON <Q1>;

   -- actual run + timing (if supported)
   EXPLAIN ANALYZE <Q1>;
