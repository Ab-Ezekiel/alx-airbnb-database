-- database-script-0x02/seed.sql
-- Seed data for ALX Airbnb MySQL schema.
-- Be sure the schema (database-script-0x01/schema.sql) has been applied first.
-- This script is idempotent-friendly: it uses deterministic variable assignment within this run.

SET FOREIGN_KEY_CHECKS = 0;

-- Optionally clear existing rows (UNCOMMENT if you want to wipe and reseed)
-- DELETE FROM messages;
-- DELETE FROM reviews;
-- DELETE FROM payments;
-- DELETE FROM bookings;
-- DELETE FROM properties;
-- DELETE FROM users;

SET FOREIGN_KEY_CHECKS = 1;

-- Create UUID variables for predictable references within this script
SET @host1 = UUID();
SET @host2 = UUID();
SET @guest1 = UUID();
SET @guest2 = UUID();

SET @prop1 = UUID();
SET @prop2 = UUID();
SET @prop3 = UUID();

SET @booking1 = UUID();
SET @booking2 = UUID();
SET @booking3 = UUID();

SET @payment1 = UUID();
SET @payment2 = UUID();
SET @payment3 = UUID();

SET @review1 = UUID();
SET @review2 = UUID();

SET @message1 = UUID();
SET @message2 = UUID();

-- Insert Users (hosts and guests)
INSERT INTO users (user_id, first_name, last_name, email, password_hash, phone_number, role)
VALUES
  (@host1, 'Emma', 'Johnson', 'emma.host@example.com', 'hashed_pw_emma', '+2347010000001', 'host'),
  (@host2, 'Carlos', 'Mendez', 'carlos.host@example.com', 'hashed_pw_carlos', '+2347010000002', 'host'),
  (@guest1, 'Abraham', 'Akpan', 'abraham.guest@example.com', 'hashed_pw_abraham', '+2347010000003', 'guest'),
  (@guest2, 'Lina', 'Okoro', 'lina.guest@example.com', 'hashed_pw_lina', '+2347010000004', 'guest');

-- Insert Properties (each owned by a host)
INSERT INTO properties (property_id, host_id, name, description, location, pricepernight)
VALUES
  (@prop1, @host1, 'Cozy Downtown Apartment', 'A compact, modern apartment in the city center.', 'Lagos, Nigeria', 45.00),
  (@prop2, @host1, 'Sunny Terrace Home', 'Spacious 2-bedroom house with a terrace.', 'Ikoyi, Lagos, Nigeria', 80.00),
  (@prop3, @host2, 'Beachside Studio', 'Studio apartment with sea view and walking distance to the beach.', 'Calabar, Cross River, Nigeria', 60.00);

-- Insert Bookings (guests book properties)
-- Booking 1: guest1 books prop1 for 3 nights
INSERT INTO bookings (booking_id, property_id, user_id, start_date, end_date, total_price, status)
VALUES
  (@booking1, @prop1, @guest1, '2025-06-10', '2025-06-13', 45.00 * 3, 'confirmed'),
  (@booking2, @prop2, @guest2, '2025-08-01', '2025-08-04', 80.00 * 3, 'confirmed'),
  (@booking3, @prop3, @guest1, '2025-09-01', '2025-09-02', 60.00 * 1, 'pending');

-- Insert Payments (one per booking as per spec)
INSERT INTO payments (payment_id, booking_id, amount, payment_method)
VALUES
  (@payment1, @booking1, 135.00, 'credit_card'),
  (@payment2, @booking2, 240.00, 'paypal'),
  (@payment3, @booking3, 60.00, 'stripe');

-- Insert Reviews (guest reviews property after stay)
INSERT INTO reviews (review_id, property_id, user_id, rating, comment)
VALUES
  (@review1, @prop1, @guest1, 5, 'Great location and very clean. Highly recommended!'),
  (@review2, @prop2, @guest2, 4, 'Spacious and comfortable. A bit noisy at night but overall good.');

-- Insert Messages between users
INSERT INTO messages (message_id, sender_id, recipient_id, message_body)
VALUES
  (@message1, @guest1, @host1, 'Hi Emma, I have a question about check-in time for the apartment.'),
  (@message2, @host1, @guest1, 'Hi Abraham, check-in is anytime after 2 PM. I will send details on arrival.');

-- Optional: show inserted ids (for manual verification if running interactively)
SELECT
  'users' AS tbl, COUNT(*) AS cnt FROM users
UNION ALL
SELECT 'properties', COUNT(*) FROM properties
UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'messages', COUNT(*) FROM messages;
