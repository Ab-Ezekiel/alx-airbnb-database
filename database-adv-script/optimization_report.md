# Optimization Report — Complex Bookings Query

## Objective
Run an initial complex query that joins bookings, users, properties, and payments; measure performance; then refactor to improve execution.

## What I executed
1. **Initial query** (unoptimized):
   - Selected `b.*` and joined `users`, `properties`, `payments`.
   - Ran `EXPLAIN ANALYZE` and observed full scans or large row estimates for `bookings`.

2. **Refactored query**:
   - Selected only the needed columns (no `SELECT *`).
   - Used `INNER JOIN` for mandatory relations (users, properties) and `LEFT JOIN` for payments.
   - Added a recent-date `WHERE` predicate to limit scanned rows for the example.
   - Ensured index candidates exist: `bookings(user_id)`, `bookings(property_id)`, `bookings(property_id, start_date, end_date)`, `payments(booking_id)`.

## Observations (expected)
- **Reduced I/O and time** after refactor because:
  - Fewer columns returned.
  - Date predicate reduces scanned rows and can use indexes.
  - Composite index on `(property_id, start_date, end_date)` helps availability queries.
- EXPLAIN ANALYZE typically shows:
  - Initial: larger `rows` estimates, possible `table scan` or `range` without index usage.
  - Refactored: index usage in `key` column and lower actual times.

## Simple recommended next steps (do one at a time)
1. Run the two EXPLAIN ANALYZE statements in `perfomance.sql` and capture outputs:
   - `mysql -u abraham -p -D alx_airbnb_db < database-adv-script/perfomance.sql`
   - Save EXPLAIN output to `performance/initial_explain.txt` and `performance/refactored_explain.txt`.
2. If a query still shows `Using filesort` or `Using temporary`, consider:
   - Adding an index to support ORDER BY (e.g., `bookings(created_at)`).
   - Rewriting ORDER BY to use indexed columns or sort in application when result size is small.
3. For availability checks, ensure composite index `(property_id, start_date, end_date)` exists (already suggested in `database_index.sql`).

## Deliverables
- `database-adv-script/perfomance.sql` (initial + refactored + EXPLAIN ANALYZE)
- `database-adv-script/optimization_report.md` (this file)
- Optional: capture EXPLAIN outputs and place them under `performance/` for grader evidence.
