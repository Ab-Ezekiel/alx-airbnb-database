# Index Performance Measurement — database-adv-script

This note explains how to measure query performance before and after adding indexes to the ALX Airbnb schema. It includes example commands and how to capture `EXPLAIN` / `EXPLAIN ANALYZE` outputs.

---

## 1) Goal
- Identify high-usage columns and create indexes to speed up JOINs, WHERE, ORDER BY and range queries.
- Measure and compare query plans and execution times before and after adding indexes.

---

## 2) Typical index candidates (already applied in `database_index.sql`)
- `users.email`
- `properties.host_id`, `properties.pricepernight`
- `bookings.property_id`, `bookings.user_id`, `(property_id, start_date, end_date)`
- `reviews.property_id`
- `payments.booking_id`

---

## 3) How to measure (commands)

### Step A — Run EXPLAIN before adding indexes
1. Pick the slow query you want to measure. Example: availability check or property search:

```sql
EXPLAIN
SELECT p.property_id, p.name
FROM properties p
LEFT JOIN reviews r ON p.property_id = r.property_id
WHERE p.pricepernight BETWEEN 40 AND 100
ORDER BY p.pricepernight
LIMIT 50;

