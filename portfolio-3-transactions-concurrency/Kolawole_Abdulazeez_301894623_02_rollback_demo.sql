SELECT vendor_product_id, stock_quantity FROM vendor_products WHERE vendor_product_id = 5;
SELECT (SELECT count(*) FROM orders) AS orders, (SELECT count(*) FROM order_items) AS order_items;

BEGIN;

WITH new_order AS (
    INSERT INTO orders (customer_id, address_id, status, total_amount)
    VALUES (2, 2, 'pending', 247500.00)
    RETURNING order_id
)
INSERT INTO order_items (order_id, vendor_product_id, quantity, unit_price)
SELECT order_id, 5, 15, 16500.00 FROM new_order;

UPDATE vendor_products
SET stock_quantity = stock_quantity - 15
WHERE vendor_product_id = 5;

ROLLBACK;

SELECT vendor_product_id, stock_quantity FROM vendor_products WHERE vendor_product_id = 5;
SELECT (SELECT count(*) FROM orders) AS orders, (SELECT count(*) FROM order_items) AS order_items;