SELECT vendor_product_id, stock_quantity FROM vendor_products WHERE vendor_product_id = 1;

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

SELECT vendor_product_id, stock_quantity FROM vendor_products WHERE vendor_product_id = 1;

COMMIT;

SELECT vendor_product_id, stock_quantity FROM vendor_products WHERE vendor_product_id = 1;

SELECT o.order_id, o.total_amount, oi.quantity, oi.unit_price
FROM orders o JOIN order_items oi USING (order_id)
ORDER BY o.order_id DESC LIMIT 1;