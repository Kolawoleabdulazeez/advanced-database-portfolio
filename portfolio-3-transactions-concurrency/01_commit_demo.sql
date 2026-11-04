-- BEFORE: stock of vendor offer 1 (should be 25)
SELECT vendor_product_id, stock_quantity FROM vendor_products WHERE vendor_product_id = 1;

-- CHUNK A: start the transaction and place an order for 2 units
BEGIN;

WITH new_order AS (
    INSERT INTO orders (customer_id, address_id, status, total_amount)
    VALUES (1, 1, 'pending', 370000.00)
    RETURNING order_id
)
INSERT INTO order_items (order_id, vendor_product_id, quantity, unit_price)
SELECT order_id, 1, 2, 185000.00 FROM new_order;

UPDATE vendor_products
SET stock_quantity = stock_quantity - 2
WHERE vendor_product_id = 1;

-- CHUNK B: look inside the open transaction (stock should show 23)
SELECT vendor_product_id, stock_quantity FROM vendor_products WHERE vendor_product_id = 1;

-- CHUNK C: make it permanent
COMMIT;

-- AFTER: the stock and the new order are saved
SELECT vendor_product_id, stock_quantity FROM vendor_products WHERE vendor_product_id = 1;

SELECT o.order_id, o.total_amount, oi.quantity, oi.unit_price
FROM orders o JOIN order_items oi USING (order_id)
ORDER BY o.order_id DESC LIMIT 1;