# Normalization — ALX Airbnb Database

**Objective:** Apply normalization (to 3NF) to the Airbnb schema and document the changes and rationale.

---

## 1. Schema recap (as designed)
- **User**(user_id, first_name, last_name, email, password_hash, phone_number, role, created_at)  
- **Property**(property_id, host_id → User.user_id, name, description, location, pricepernight, created_at, updated_at)  
- **Booking**(booking_id, property_id → Property.property_id, user_id → User.user_id, start_date, end_date, total_price, status, created_at)  
- **Payment**(payment_id, booking_id → Booking.booking_id, amount, payment_date, payment_method)  
- **Review**(review_id, property_id → Property.property_id, user_id → User.user_id, rating, comment, created_at)  
- **Message**(message_id, sender_id → User.user_id, recipient_id → User.user_id, message_body, sent_at)

---

## 2. Functional dependencies (FD) — quick notes
Write these out to reason about normalization:

- `User`: `user_id → (first_name, last_name, email, password_hash, phone_number, role, created_at)`
- `Property`: `property_id → (host_id, name, description, location, pricepernight, created_at, updated_at)`
- `Booking`: `booking_id → (property_id, user_id, start_date, end_date, total_price, status, created_at)`
- `Payment`: `payment_id → (booking_id, amount, payment_date, payment_method)`
- `Review`: `review_id → (property_id, user_id, rating, comment, created_at)`
- `Message`: `message_id → (sender_id, recipient_id, message_body, sent_at)`

---

## 3. 1NF check
- All attributes are atomic (no CSV lists or repeating groups). ✅

---

## 4. 2NF check
- All tables use single-column UUID primary keys; no composite-key partial dependency problem exists at this time. ✅

---

## 5. 3NF check (look for transitive dependencies)
**Potential issues found:**

1. **`Booking.total_price`**  
   - **Reason:** `total_price` is *derived* from `pricepernight` × nights (+ fees). Storing it risks inconsistency if `pricepernight` or dates change.  
   - **Options:**  
     - **A (normalize):** remove `total_price` and compute on demand (safe, normalized).  
     - **B (practical):** keep `total_price` as a denormalized field but record it at booking time and protect it (application logic or trigger) so it represents price at time of booking.  
   - **Recommendation:** Keep it for now (practical) but treat as derived and ensure booking creation computes & stores it atomically.

2. **`Review` not linked to `Booking`**  
   - **Reason:** With current columns, a user could post a review for a property even without a booking (data integrity problem).  
   - **Fix:** Add `booking_id` FK to `Review`, and enforce (via app logic or DB constraint/trigger) that the `Review.booking_id` references a `Booking` where `Booking.user_id = Review.user_id` and `Booking.property_id = Review.property_id`.  
   - **Result:** Reviews are grounded in actual stays → removes possibility of orphan or fake reviews.

3. **`Property.location` is a single string** (optional)  
   - **Reason:** If you need to query by city/state/country, a single `location` text field is limiting and not atomic.  
   - **Fix (optional):** Replace `location` with `street, city, state, country, postal_code` or create a separate `Address` table referenced by `Property.address_id`.  
   - **Recommendation:** Optional — implement if project needs regional searches.

---

## 6. Concrete normalization changes (summary)
1. **Modify `Review`**  
   - Add: `booking_id` (FK → `Booking.booking_id`)  
   - Enforce (app/DB): `Booking.booking_id = Review.booking_id` and `Booking.user_id = Review.user_id` and `Booking.property_id = Review.property_id`.

2. **Treat `Booking.total_price` as derived**  
   - Keep it if you want historical snapshot and fast reads — but compute and store it at create-time; otherwise remove it and compute when needed.

3. **Optional:** split `Property.location` into atomic address columns or add an `Address` table.

4. **Optional improvements** (not required for 3NF): add `payment_status`, `transaction_reference` to `Payment` to improve traceability.

---

## 7. How to reflect changes in the ERD
- Add `booking_id` FK to `Review` (link Review → Booking).  
- Optionally draw `Address` and link `Property.address_id → Address.address_id`.  
- Annotate `Booking.total_price` as `derived` (or show as normal field if you keep it).

---

## 8. Test / validate (how to confirm 3NF)
- For each table:
  1. List the primary key.
  2. List all non-key attributes.
  3. Ensure each non-key attribute is *fully functionally dependent* on the primary key (not on another non-key attribute).
- Ensure no attribute is both derivable from other attributes and stored unless intentionally denormalized (and documented).

---

## 9. Next steps / implementation notes
1. Update the Draw.io ERD to reflect `Review.booking_id` (and optional address change).  
2. Commit this `normalization.md` to the **repo root**.  
3. After ERD + normalization are confirmed, proceed to SQL DDL (create tables) — at that stage we will translate the final design into `CREATE TABLE` scripts.

---

**End of normalization document.**
