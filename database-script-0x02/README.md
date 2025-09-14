# database-script-0x02 — Seed data (MySQL)

This folder contains a seed script to populate the ALX Airbnb database with sample data.

## Files
- `seed.sql` — INSERT statements to create sample users, properties, bookings, payments, reviews, and messages.

## Pre-requisites
- The schema must already be applied (run `database-script-0x01/schema.sql` first).
- MySQL 8+ recommended.

## How to run
1. Ensure your database exists (example used here: `alx_airbnb_db`):
```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS alx_airbnb_db;"
