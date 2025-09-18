-- 1) Aggregation: Total number of bookings by each user
-- -----------------------------------------------------
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b
    ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC;

--------------------------------------------------------------------------------

-- 2) Window Function: Rank properties based on number of bookings
-- ---------------------------------------------------------------
SELECT 
    p.property_id,
    p.name AS property_name,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM properties p
LEFT JOIN bookings b
    ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY booking_rank;

--------------------------------------------------------------------------------

-- 3) Window function with DENSE_RANK: Alternative ranking (no gaps)
-- ---------------------------------------------------------------
SELECT 
  p.property_id,
  p.name AS property_name,
  COUNT(b.booking_id) AS total_bookings,
  DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY booking_rank;


--------------------------------------------------------------------------------

-- 4) Window function with ROW_NUMBER: Unique ordering even with ties
-- ---------------------------------------------------------------
SELECT 
  p.property_id,
  p.name AS property_name,
  COUNT(b.booking_id) AS total_bookings,
  ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC, p.name ASC) AS booking_rownum
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY booking_rownum;
