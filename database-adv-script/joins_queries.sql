-- database-adv-script/joins_queries.sql
-- Joins examples tailored for your MySQL schema (users, properties, bookings, reviews).
-- MySQL 8+ recommended.

--------------------------------------------------------------------------------
-- 1) INNER JOIN
-- Retrieve all bookings with the user who made each booking.
--------------------------------------------------------------------------------

SELECT
  b.booking_id,
  b.property_id,
  b.user_id,
  u.first_name,
  u.last_name,
  u.email,
  b.start_date,
  b.end_date,
  b.total_price,
  b.status
FROM bookings b
INNER JOIN users u
  ON b.user_id = u.user_id
ORDER BY b.start_date DESC, b.booking_id;

--------------------------------------------------------------------------------
-- 2) LEFT JOIN
-- Retrieve all properties and aggregated review stats (include properties with no reviews).
--------------------------------------------------------------------------------

SELECT
  p.property_id,
  p.name AS property_name,
  p.pricepernight,
  COALESCE(rv.num_reviews, 0) AS num_reviews,
  COALESCE(rv.avg_rating, 0.0) AS avg_rating
FROM properties p
LEFT JOIN (
  SELECT
    r.property_id,
    COUNT(*) AS num_reviews,
    ROUND(AVG(r.rating), 2) AS avg_rating
  FROM reviews r
  GROUP BY r.property_id
) rv ON rv.property_id = p.property_id
ORDER BY avg_rating DESC, num_reviews DESC;

--------------------------------------------------------------------------------
-- 3) FULL OUTER JOIN (MySQL workaround)
-- MySQL does not support FULL OUTER JOIN natively. Use UNION of LEFT and RIGHT (or LEFT + RIGHT with COALESCE).
-- This returns all users and all bookings; rows without matches will have NULLs in booking/user columns.
--------------------------------------------------------------------------------

-- Left side: all users with their bookings (if any)
SELECT
  u.user_id,
  u.email,
  b.booking_id,
  b.property_id,
  b.start_date,
  b.end_date,
  b.status AS booking_status
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id

UNION

-- Right side: all bookings with their users (if any)
SELECT
  u2.user_id,
  u2.email,
  b2.booking_id,
  b2.property_id,
  b2.start_date,
  b2.end_date,
  b2.status AS booking_status
FROM bookings b2
LEFT JOIN users u2 ON u2.user_id = b2.user_id

ORDER BY user_id, start_date;

--------------------------------------------------------------------------------
-- Notes:
-- - The FULL OUTER JOIN fallback may produce duplicate rows if a user-booking pair appears identical in both sides;
--   using UNION instead of UNION ALL removes duplicates.
-- - For very large datasets, consider adding WHERE clauses or pagination (LIMIT/OFFSET).
--------------------------------------------------------------------------------
