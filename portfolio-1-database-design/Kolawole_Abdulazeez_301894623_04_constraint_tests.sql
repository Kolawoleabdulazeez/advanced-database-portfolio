---shoptackle constraints query added
-- 1. A second successful payment for order 1 (should be rejected by the partial unique index)
INSERT INTO payments (order_id, method, amount, status, paid_at)
VALUES (1, 'card', 215000.00, 'successful', now());

-- 2. Negative quantity (CHECK constraint)
INSERT INTO order_items (order_id, vendor_product_id, quantity, unit_price)
VALUES (3, 1, -2, 185000.00);

-- 3. Duplicate email (UNIQUE constraint)
INSERT INTO customers (full_name, email, password_hash)
VALUES ('Another Person', 'amina.yusuf@example.com', 'x');

-- 4. Rating out of range (CHECK constraint)
INSERT INTO reviews (customer_id, product_id, rating) VALUES (3, 2, 6);

-- 5. Order for a customer that doesn't exist (foreign key)
INSERT INTO orders (customer_id, address_id, total_amount) VALUES (999, 1, 1000.00);

-- 6. Delete a customer who has orders (ON DELETE RESTRICT)
DELETE FROM customers WHERE customer_id = 1;