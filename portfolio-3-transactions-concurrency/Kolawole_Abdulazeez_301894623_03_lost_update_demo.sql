-- Portfolio 3: Lost update demo (two concurrent sessions)
-- Shoptackles, vendor offer 5 (vendor_product_id = 5)
--
-- HOW TO RUN: open two Query Tool tabs on ecommerce_db, called Tab A and Tab B
-- (each tab is a separate session). Run ONE statement at a time, in the order
-- of the step numbers below, switching tabs where indicated.
--
-- SCENARIO: only 1 unit is left. Two customers each read the stock, decide
-- there is enough, and write the new stock. Both succeed, so the shop oversells.

-- =====================================================================
-- SETUP (either tab, auto-commit): leave exactly 1 unit in stock
-- =====================================================================
UPDATE vendor_products SET stock_quantity = 1 WHERE vendor_product_id = 5;

-- =====================================================================
-- STEP 1 - TAB A: start a transaction
-- =====================================================================
BEGIN;

-- STEP 2 - TAB A: read the stock (expected: 1)
SELECT stock_quantity FROM vendor_products WHERE vendor_product_id = 5;

-- =====================================================================
-- STEP 3 - TAB B: start a transaction
-- =====================================================================
BEGIN;

-- STEP 4 - TAB B: read the stock (expected: 1, B also sees the last unit)
SELECT stock_quantity FROM vendor_products WHERE vendor_product_id = 5;

-- =====================================================================
-- STEP 5 - TAB A: sell the last unit (A calculated 1 - 1 = 0)
-- =====================================================================
UPDATE vendor_products SET stock_quantity = 0 WHERE vendor_product_id = 5;

-- STEP 6 - TAB A: record customer 1's order
WITH new_order AS (
    INSERT INTO orders (customer_id, address_id, status, total_amount)
    VALUES (1, 1, 'pending', 16500.00)
    RETURNING order_id
)
INSERT INTO order_items (order_id, vendor_product_id, quantity, unit_price)
SELECT order_id, 5, 1, 16500.00 FROM new_order;

-- STEP 7 - TAB A: make it permanent
COMMIT;

-- =====================================================================
-- STEP 8 - TAB B: B still believes the stock is 1, so it also "sells the last unit"
-- (expected: UPDATE 1, no error and no warning)
-- =====================================================================
UPDATE vendor_products SET stock_quantity = 0 WHERE vendor_product_id = 5;

-- STEP 9 - TAB B: record customer 2's order
WITH new_order AS (
    INSERT INTO orders (customer_id, address_id, status, total_amount)
    VALUES (2, 2, 'pending', 16500.00)
    RETURNING order_id
)
INSERT INTO order_items (order_id, vendor_product_id, quantity, unit_price)
SELECT order_id, 5, 1, 16500.00 FROM new_order;

-- STEP 10 - TAB B: make it permanent
COMMIT;

-- =====================================================================
-- CHECK THE DAMAGE (either tab)
-- =====================================================================
-- Stock is 0 (looks normal on its own)
SELECT vendor_product_id, stock_quantity FROM vendor_products WHERE vendor_product_id = 5;

-- ...but two order lines of quantity 1 were sold from 1 unit (the oversell)
SELECT order_id, quantity FROM order_items
WHERE vendor_product_id = 5
ORDER BY order_id DESC LIMIT 2;

-- One-result summary: stock 0, units sold in this demo = 2
SELECT vp.stock_quantity,
       (SELECT sum(oi.quantity)
        FROM order_items oi
        WHERE oi.vendor_product_id = 5 AND oi.order_id > 200005) AS units_sold_in_demo
FROM vendor_products vp
WHERE vp.vendor_product_id = 5;

-- =====================================================================
-- WHY THIS HAPPENS
-- Both sessions read the stock (1) before either one wrote. Under PostgreSQL's
-- default READ COMMITTED isolation, Tab B's UPDATE did not check that the value
-- it had read was still current, so it overwrote Tab A's change. This is a
-- lost update. The fixes are shown in 04_lost_update_fixes.sql.
-- =====================================================================