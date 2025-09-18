# Joins Queries — database-adv-script

This folder contains SQL examples demonstrating INNER JOIN, LEFT JOIN (with aggregation), and a FULL OUTER JOIN fallback for MySQL (using UNION).

## Files
- `joins_queries.sql` — SQL queries (tailored to schema.sql in this repo).

## How to run
### MySQL (CLI)
```bash
mysql -u <user> -p <database> < database-adv-script/joins_queries.sql



# Subqueries Practice

This folder contains SQL examples demonstrating both **correlated** and **non-correlated** subqueries, using the `Airbnb` database schema (`users`, `properties`, `bookings`, `reviews`).

## Files
- `subqueries.sql` → Contains two queries:
  1. **Non-Correlated Subquery**: Finds all properties where the average rating is greater than 4.0.
  2. **Correlated Subquery**: Finds users who have made more than 3 bookings.

## Example Queries

### 1. Non-Correlated Subquery
```sql
SELECT p.property_id, p.name, p.pricepernight
FROM properties p
WHERE p.property_id IN (
  SELECT r.property_id
  FROM reviews r
  GROUP BY r.property_id
  HAVING AVG(r.rating) > 4.0
);


# Aggregations and Window Functions

## 1. Aggregations
Query to find the total number of bookings made by each user using `COUNT` and `GROUP BY`.

```sql
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
