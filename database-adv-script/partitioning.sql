-- partitioning.sql
-- Simple, safe approach to partition bookings by start_date (RANGE COLUMNS)
-- Run this on a test/staging DB first. Do NOT run blindly on production.
-- Recommended workflow:
-- 1) Backup original bookings table (or work on a copy).
-- 2) Create partitioned copy bookings_part, copy data, test queries.
-- 3) If ok, switch (rename) tables during maintenance window.

-- STEP 0: Create a safe copy of the original table (structure + data copy optional)
CREATE TABLE IF NOT EXISTS bookings_backup AS
SELECT * FROM bookings WHERE 1=0; -- structure only (empty)

-- (Optional) copy current data to backup (be careful with large data)
-- INSERT INTO bookings_backup SELECT * FROM bookings;

-- STEP 1: Create partitioned table bookings_part (no foreign keys here to avoid FK/partition restrictions)
DROP TABLE IF EXISTS bookings_part;
CREATE TABLE bookings_part (
  booking_id CHAR(36) NOT NULL PRIMARY KEY,
  property_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_price DECIMAL(12,2) NOT NULL,
  status ENUM('pending','confirmed','canceled') NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
PARTITION BY RANGE COLUMNS(start_date) (
  PARTITION p_2023 VALUES LESS THAN ('2024-01-01'),
  PARTITION p_2024 VALUES LESS THAN ('2025-01-01'),
  PARTITION p_2025 VALUES LESS THAN ('2026-01-01'),
  PARTITION p_2026 VALUES LESS THAN ('2027-01-01'),
  PARTITION p_future VALUES LESS THAN (MAXVALUE)
);

-- STEP 2: Copy data from original bookings into bookings_part
-- For large tables, copy in batches. This example copies all rows (careful).
INSERT INTO bookings_part
SELECT * FROM bookings;

-- STEP 3: Create indexes on the partitioned table to support typical queries
CREATE INDEX idx_bpart_property_dates ON bookings_part (property_id, start_date, end_date);
CREATE INDEX idx_bpart_user_id ON bookings_part (user_id);
CREATE INDEX idx_bpart_created_at ON bookings_part (created_at);

-- STEP 4: Example EXPLAIN tests to run BEFORE/AFTER (run manually and save outputs)
-- A) Availability query (date range for a property)
EXPLAIN FORMAT=JSON
SELECT b.booking_id
FROM bookings /* original table */
WHERE b.property_id = 'c3df9e9c-91a9-11f0-b5c5-80ce629dfc40'
  AND NOT (b.end_date <= '2025-06-10' OR b.start_date >= '2025-06-13');

EXPLAIN FORMAT=JSON
SELECT b.booking_id
FROM bookings_part /* partitioned copy */
WHERE b.property_id = 'c3df9e9c-91a9-11f0-b5c5-80ce629dfc40'
  AND NOT (b.end_date <= '2025-06-10' OR b.start_date >= '2025-06-13');

-- B) Range scan by start_date
EXPLAIN FORMAT=JSON
SELECT COUNT(*) FROM bookings WHERE start_date BETWEEN '2025-01-01' AND '2025-12-31';

EXPLAIN FORMAT=JSON
SELECT COUNT(*) FROM bookings_part WHERE start_date BETWEEN '2025-01-01' AND '2025-12-31';

-- STEP 5: If validation is successful, you may swap tables (do during maintenance)
-- WARNING: The following steps are optional and require careful handling of FKs and downtime.
-- Recommended: drop foreign keys, rename original to old, rename bookings_part to bookings, recreate FKs.

-- Example (DO NOT RUN UNLESS YOU FULLY UNDERSTAND AND BACKED UP):
-- RENAME TABLE bookings TO bookings_old, bookings_part TO bookings;
-- Recreate foreign keys as needed (test carefully).

-- STEP 6: How to revert (if needed)
-- If you want to go back to original:
-- 1) Rename tables or copy data back from bookings_backup.
-- 2) DROP TABLE bookings_part; RENAME bookings_backup TO bookings;
