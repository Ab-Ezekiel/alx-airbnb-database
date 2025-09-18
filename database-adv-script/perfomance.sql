-- perfomance.sql
-- Initial complex query, EXPLAIN ANALYZE, refactored query, EXPLAIN ANALYZE
-- MySQL/MariaDB (run with mysql or sudo mysql). Adjust IDs/dates for your dataset.

-- ======================
-- 0) Helpful note: run with
-- sudo mysql -D alx_airbnb_db < database-adv-script/perfomance.sql
-- or run queries interactively and inspect the EXPLAIN outputs.
-- ======================

/* ======================
   A) INITIAL COMPLEX QUERY
   - Retrieves ALL bookings with user, property, and payment details.
   - Uses SELECT * to show the unoptimized form.
   ====================== */

EXPLAIN ANALYZE
SELECT
  b.*,
  u.user_id AS u_user_id, u.first_name AS u_first_name, u.last_name AS u_last_name, u.email AS u_email,
  p.property_id AS p_property_id, p.name AS p_name, p.pricepernight AS p_price,
  pay.payment_id AS pay_id, pay.amount AS pay_amount, pay.payment_method AS pay_method
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON pay.booking_id = b.booking_id
ORDER BY b.created_at DESC
LIMIT 500; -- LIMIT to keep EXPLAIN runs reasonable on large datasets

/* 
  Note: INITIAL query uses joins and SELECT b.* (returns all columns).
  EXPLAIN ANALYZE will show scans, chosen keys, and actual times.
*/

-- ======================
-- B) REFACTORED QUERY (optimizations)
-- 1. Select only required columns (reduces data transfer)
-- 2. Use LEFT JOIN only for payments since not every booking may have a payment
-- 3. Ensure indexes exist: bookings(user_id), bookings(property_id), payments(booking_id)
-- 4. Use LIMIT + WHERE filters where applicable to reduce scanned rows
-- ======================

EXPLAIN ANALYZE
SELECT
  b.booking_id,
  b.property_id,
  b.user_id,
  b.start_date,
  b.end_date,
  b.status,
  u.first_name,
  u.last_name,
  u.email,
  p.name AS property_name,
  p.pricepernight,
  pay.amount AS payment_amount,
  pay.payment_method
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON pay.booking_id = b.booking_id
WHERE b.created_at >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)  -- narrow to recent year
ORDER BY b.created_at DESC
LIMIT 500;

-- ======================
-- C) NOTES:
-- - If you cannot run EXPLAIN ANALYZE (older server), replace with EXPLAIN FORMAT=JSON <query>;
-- - To test an alternative optimization, try pushing the date filter into an indexed predicate:
--   WHERE b.property_id = '<some-uuid>' AND b.start_date BETWEEN '2025-06-01' AND '2025-06-30'
--   which can use the composite index (property_id, start_date, end_date) if present.
-- ======================
