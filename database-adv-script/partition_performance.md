# Partition Performance — bookings table

## Goal
Partition the `bookings` table by `start_date` to improve performance for date-range queries.

## What we did (recommended safe steps)
1. Created an empty `bookings_part` table partitioned by `start_date` (RANGE COLUMNS) and defined partitions per year.
2. Copied data from `bookings` into `bookings_part` (for large data, copy in batches).
3. Created supporting indexes on `bookings_part`:
   - `(property_id, start_date, end_date)`
   - `(user_id)`
   - `(created_at)`
4. Ran `EXPLAIN FORMAT=JSON` (or `EXPLAIN ANALYZE` if available) on representative queries against both `bookings` and `bookings_part` and recorded the outputs.

## Example queries to run and save outputs
Run (replace `<user>` with your DB user):

```bash
# Availability check - original
mysql -u <user> -p -D alx_airbnb_db -e "EXPLAIN FORMAT=JSON SELECT b.booking_id FROM bookings b WHERE b.property_id = 'c3df9e9c-91a9-11f0-b5c5-80ce629dfc40' AND NOT (b.end_date <= '2025-06-10' OR b.start_date >= '2025-06-13');" > performance/explain_availability_before.json

# Availability check - partitioned
mysql -u <user> -p -D alx_airbnb_db -e "EXPLAIN FORMAT=JSON SELECT b.booking_id FROM bookings_part b WHERE b.property_id = 'c3df9e9c-91a9-11f0-b5c5-80ce629dfc40' AND NOT (b.end_date <= '2025-06-10' OR b.start_date >= '2025-06-13');" > performance/explain_availability_after.json

# Date-range aggregation - original
mysql -u <user> -p -D alx_airbnb_db -e "EXPLAIN FORMAT=JSON SELECT COUNT(*) FROM bookings WHERE start_date BETWEEN '2025-01-01' AND '2025-12-31';" > performance/explain_range_before.json

# Date-range aggregation - partitioned
mysql -u <user> -p -D alx_airbnb_db -e "EXPLAIN FORMAT=JSON SELECT COUNT(*) FROM bookings_part WHERE start_date BETWEEN '2025-01-01' AND '2025-12-31';" > performance/explain_range_after.json
