-- database-adv-script/subqueries.sql
-- Subquery practice: non-correlated and correlated examples
-- MySQL 8+ recommended

--------------------------------------------------------------------------------
-- 1) Non-Correlated Subquery
-- Find all properties where the average rating is greater than 4.0
--------------------------------------------------------------------------------

SELECT
  p.property_id,
  p.name AS property_name,
  p.pricepernight
FROM properties p
WHERE p.property_id IN (
  SELECT r.property_id
  FROM reviews r
  GROUP BY r.property_id
  HAVING AVG(r.rating) > 4.0
)
ORDER BY p.property_id;

--------------------------------------------------------------------------------
-- 2) Correlated Subquery
-- Find all users who have made more than 3 bookings
--------------------------------------------------------------------------------

SELECT
  u.user_id,
  u.first_name,
  u.last_name,
  u.email
FROM users u
WHERE (
  SELECT COUNT(*)
  FROM bookings b
  WHERE b.user_id = u.user_id
) > 3
ORDER BY u.user_id;
