# ERD Requirements — ALX Airbnb Database

## Purpose
Define entities, attributes, and relationships for an Airbnb-like DB. This file accompanies the Draw.io diagram (airbnb-erd.drawio) and an exported PNG.

## Entities (summary)
- **User**
  - user_id (PK), first_name, last_name, email (unique), password_hash, phone_number, role (guest|host|admin), created_at
- **Property**
  - property_id (PK), host_id (FK → User.user_id), name, description, location, pricepernight, created_at, updated_at
- **Booking**
  - booking_id (PK), property_id (FK), user_id (FK), start_date, end_date, total_price, status (pending|confirmed|canceled), created_at
- **Payment**
  - payment_id (PK), booking_id (FK), amount, payment_date, payment_method (credit_card|paypal|stripe)
- **Review**
  - review_id (PK), property_id (FK), user_id (FK), rating (1-5), comment, created_at
- **Message**
  - message_id (PK), sender_id (FK), recipient_id (FK), message_body, sent_at

## Relationships (high level)
- User (host) 1 — * Property
- User (guest) 1 — * Booking
- Property 1 — * Booking
- Booking 1 — 1..* Payment (or 1 payment)
- Property 1 — * Review
- User 1 — * Message (sender/recipient)

## Files in this folder
- airbnb-erd.drawio  ← editable draw.io file
- airbnb-erd.png     ← exported image for preview
- requirements.md    ← this file
