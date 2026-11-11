-- Q1: Order history for one customer (key operation 17)
SELECT o.order_id, o.order_date, o.status, o.total_amount,
       p.name AS product, oi.quantity, oi.unit_price
FROM orders o
JOIN order_items oi     ON oi.order_id = o.order_id
JOIN vendor_products vp ON vp.vendor_product_id = oi.vendor_product_id
JOIN products p         ON p.product_id = vp.product_id
WHERE o.customer_id = 12345
ORDER BY o.order_date DESC;

-- Q2: Vendor sales summary for the last 90 days (key operation 17)
SELECT vp.vendor_id,
       count(DISTINCT o.order_id)        AS orders,
       sum(oi.quantity)                  AS units_sold,
       sum(oi.quantity * oi.unit_price)  AS revenue
FROM order_items oi
JOIN vendor_products vp ON vp.vendor_product_id = oi.vendor_product_id
JOIN orders o           ON o.order_id = oi.order_id
WHERE vp.vendor_id = 50
  AND o.status IN ('paid', 'shipped', 'delivered')
  AND o.order_date >= now() - interval '90 days'
GROUP BY vp.vendor_id;

-- Q3: Compare vendor prices for one product (key operation 7)
SELECT p.name, v.business_name, vp.price, vp.stock_quantity
FROM products p
JOIN vendor_products vp ON vp.product_id = p.product_id
JOIN vendors v          ON v.vendor_id = vp.vendor_id
WHERE p.name = 'Product 2500'
  AND vp.is_active
ORDER BY vp.price;

-- Q4: Ten best-selling products in the last 30 days
SELECT p.product_id, p.name, sum(oi.quantity) AS units_sold
FROM order_items oi
JOIN orders o           ON o.order_id = oi.order_id
JOIN vendor_products vp ON vp.vendor_product_id = oi.vendor_product_id
JOIN products p         ON p.product_id = vp.product_id
WHERE o.order_date >= now() - interval '30 days'
  AND o.status IN ('paid', 'shipped', 'delivered')
GROUP BY p.product_id, p.name
ORDER BY units_sold DESC
LIMIT 10;

-- Q5: Shipments for one vendor that are still awaiting delivery (key operation 14)
SELECT d.delivery_id, d.order_id, d.status, d.shipped_at, o.customer_id
FROM deliveries d
JOIN orders o ON o.order_id = d.order_id
WHERE d.vendor_id = 77
  AND d.status = 'shipped';