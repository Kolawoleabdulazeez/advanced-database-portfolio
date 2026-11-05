-- Portfolio 3: Isolation levels demo (two concurrent sessions)
-- Vendor offer 2 (vendor_product_id = 2), price 15000.00.
-- Run in two Query Tool tabs (Tab A and Tab B), one statement at a time.
-- Tab B runs in auto-commit, so its change is saved immediately.

-- START (Tab A): check the starting price (expected 15000.00)
SELECT vendor_product_id, price FROM vendor_products WHERE vendor_product_id = 2;

-- =====================================================================
-- PART 1: READ COMMITTED (the PostgreSQL default)
-- =====================================================================
-- Tab A
BEGIN ISOLATION LEVEL READ COMMITTED;
-- Tab A: first read (15000.00)
SELECT vendor_product_id, price FROM vendor_products WHERE vendor_product_id = 2;
-- Tab B: change the price (committed at once)
UPDATE vendor_products SET price = 16000.00 WHERE vendor_product_id = 2;
-- Tab A: same read again (16000.00, the value changed inside one transaction)
SELECT vendor_product_id, price FROM vendor_products WHERE vendor_product_id = 2;
-- Tab A
COMMIT;
-- Either tab: reset
UPDATE vendor_products SET price = 15000.00 WHERE vendor_product_id = 2;

-- =====================================================================
-- PART 2: REPEATABLE READ
-- =====================================================================
-- Tab A
BEGIN ISOLATION LEVEL REPEATABLE READ;
-- Tab A: first read (15000.00). This takes the transaction's snapshot.
SELECT vendor_product_id, price FROM vendor_products WHERE vendor_product_id = 2;
-- Tab B: change the price (committed at once)
UPDATE vendor_products SET price = 16000.00 WHERE vendor_product_id = 2;
-- Tab A: same read again (still 15000.00, because it reads from its snapshot)
SELECT vendor_product_id, price FROM vendor_products WHERE vendor_product_id = 2;
-- Tab A
COMMIT;
-- Tab A: a new transaction sees the current value (16000.00)
SELECT vendor_product_id, price FROM vendor_products WHERE vendor_product_id = 2;
-- Either tab: reset
UPDATE vendor_products SET price = 15000.00 WHERE vendor_product_id = 2;