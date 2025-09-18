-- database-adv-script/database_index.sql
-- Indexes to improve query performance for the ALX Airbnb schema (MySQL / MariaDB)
-- Run the EXPLAINs before applying indexes, then run the CREATE INDEX statements,
-- then re-run the EXPLAINs to compare.

-- NOTE: some indexes (like on primary keys) already exist; these are focused on
-- high-usage columns: JOIN/WHERE/ORDER BY candidates.

-- 1) Users
-- email is commonly searched / used for login. There is already idx_users_email in schema,
-- but keep this as a check if missing.
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- 2) Properties
-- filter/join by host and search by price/location
CREATE INDEX IF NOT EXISTS idx_properties_host_id ON properties (host_id);
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties (pricepernight);

-- If you often search by location text, consider a functional or full-text index:
-- (MySQL fulltext example for name/description; only if you use MATCH() queries)
-- CREATE FULLTEXT INDEX idx_properties_fulltext ON properties (name, description);

-- 3) Bookings
-- frequent joins and availability checks: property_id and date ranges.
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings (property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings (user_id);
-- composite index for queries that filter by property_id and date range
CREATE INDEX IF NOT EXISTS idx_bookings_property_dates ON bookings (property_id, start_date, end_date);

-- 4) Reviews
CREATE INDEX IF NOT EXISTS idx_reviews_property_id ON reviews (property_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews (user_id);

-- 5) Payments
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments (booking_id);

-- Optional: if you order or filter by created_at on large tables:
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings (created_at);
CREATE INDEX IF NOT EXISTS idx_properties_created_at ON properties (created_at);

-- Useful: help cleanup / revert (run if you need to drop these indexes)
-- DROP INDEX idx_users_email ON users;
-- DROP INDEX idx_properties_host_id ON properties;
-- DROP INDEX idx_properties_price ON properties;
-- DROP INDEX idx_bookings_property_id ON bookings;
-- DROP INDEX idx_bookings_user_id ON bookings;
-- DROP INDEX idx_bookings_property_dates ON bookings;
-- DROP INDEX idx_reviews_property_id ON reviews;
-- DROP INDEX idx_reviews_user_id ON reviews;
-- DROP INDEX idx_payments_booking_id ON payments;
-- DROP INDEX idx_bookings_created_at ON bookings;
-- DROP INDEX idx_properties_created_at ON properties;


-- Measure performance before/after indexes

-- Example 1: property price filter and join
EXPLAIN ANALYZE
SELECT p.property_id, p.name
FROM properties p
LEFT JOIN reviews r ON p.property_id = r.property_id
WHERE p.pricepernight BETWEEN 40 AND 100
ORDER BY p.pricepernight
LIMIT 50;

-- Example 2: booking availability check
EXPLAIN ANALYZE
SELECT b.*
FROM bookings b
WHERE b.property_id = 'c3df9e9c-91a9-11f0-b5c5-80ce629dfc40'
  AND NOT (b.end_date <= '2025-06-10' OR b.start_date >= '2025-06-13');
