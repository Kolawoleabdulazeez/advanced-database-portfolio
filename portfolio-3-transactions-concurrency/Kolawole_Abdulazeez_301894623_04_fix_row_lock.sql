-- Portfolio 3: Fix for the lost update using row locking (SELECT ... FOR UPDATE)
-- Run in two Query Tool tabs (Tab A and Tab B), one statement at a time.

-- Reset to the starting state (either tab, auto-commit)
DELETE FROM orders WHERE order_id IN (200007, 200008);   -- removes the oversold demo orders
UPDATE vendor_products SET stock_quantity = 1 WHERE vendor_product_id = 5;

-- STEP 1 - TAB A
BEGIN;

-- STEP 2 - TAB A: read the stock AND lock the row (expected: 1)
SELECT stock_quantity FROM vendor_products WHERE vendor_product_id = 5 FOR UPDATE;

-- STEP 3 - TAB B
BEGIN;

-- STEP 4 - TAB B: the same locking read. It WAITS until Tab A finishes.
SELECT stock_quantity FROM vendor_products WHERE vendor_product_id = 5 FOR UPDATE;

-- STEP 5 - TAB A: sell the last unit
UPDATE vendor_products SET stock_quantity = 0 WHERE vendor_product_id = 5;

-- STEP 6 - TAB A: record customer 1's order
WITH new_order AS (
    INSERT INTO orders (customer_id, address_id, status, total_amount)
    VALUES (1, 1, 'pending', 16500.00)
    RETURNING order_id
)
INSERT INTO order_items (order_id, vendor_product_id, quantity, unit_price)
SELECT order_id, 5, 1, 16500.00 FROM new_order;

-- STEP 7 - TAB A: commit (this releases the lock)
COMMIT;

-- STEP 8 - TAB B: its waiting query now returns 0 (the NEW value).
-- The application sees "sold out" and places no order.
-- STEP 9 - TAB B
ROLLBACK;

-- CHECK THE RESULT (either tab)
SELECT vendor_product_id, stock_quantity FROM vendor_products WHERE vendor_product_id = 5;

SELECT order_id, quantity FROM order_items
WHERE vendor_product_id = 5 AND order_id > 200005;   -- exactly one row

-- WHY IT WORKS
-- FOR UPDATE makes the first reader lock the row. The second reader must wait,
-- and when it continues it sees the committed stock (0), not the stale value (1).
-- Check-then-write is now safe, so the oversell cannot happen.