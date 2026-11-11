-- Portfolio 3: Concurrent payments for one order (partial unique index under concurrency)
-- Order 3 has no payments at the start. Run in two Query Tool tabs, one statement at a time.
-- The index: CREATE UNIQUE INDEX uq_one_successful_payment_per_order
--            ON payments (order_id) WHERE status = 'successful';   (Portfolio 1)

-- START (either tab): order 3 has no payments
SELECT payment_id, order_id, status FROM payments WHERE order_id = 3;

-- STEP 1 - TAB A
BEGIN;
-- STEP 2 - TAB A: record a successful payment. DO NOT COMMIT YET.
INSERT INTO payments (order_id, method, amount, status, paid_at)
VALUES (3, 'card', 16500.00, 'successful', now());

-- STEP 3 - TAB B
BEGIN;
-- STEP 4 - TAB B: try to record a second successful payment for the same order.
-- It WAITS, because Tab A's row is not committed yet.
INSERT INTO payments (order_id, method, amount, status, paid_at)
VALUES (3, 'bank_transfer', 16500.00, 'successful', now());

-- STEP 5 - TAB A: commit
COMMIT;
-- STEP 6 - TAB B: its waiting insert now fails with
--   ERROR: duplicate key value violates unique constraint "uq_one_successful_payment_per_order"
--   SQL state 23505
ROLLBACK;

-- RESULT (either tab): exactly one successful payment for order 3
SELECT payment_id, order_id, method, status FROM payments WHERE order_id = 3;

-- WHY IT WORKS
-- The partial unique index covers only rows with status = 'successful'. While Tab A's
-- row is uncommitted, Tab B cannot know whether it will exist, so it waits. Once Tab A
-- commits, Tab B's row would break the rule and is refused. The rule is enforced by the
-- database, not by application code.