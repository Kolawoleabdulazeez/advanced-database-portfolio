-- 50,000 customers, each with one default address so as to populate the database
INSERT INTO customers (full_name, email, phone, password_hash)
SELECT 'Customer ' || g, 'customer' || g || '@example.com',
       '080' || lpad(g::text, 8, '0'), 'placeholder_hash'
FROM generate_series(1, 50000) g;

INSERT INTO addresses (customer_id, street, city, state, is_default)
SELECT c.customer_id,
       (1 + c.customer_id % 200) || ' Sample Street',
       (ARRAY['Ikeja','Lekki','Garki','Ibadan','Port Harcourt','Kano'])[1 + c.customer_id % 6],
       (ARRAY['Lagos','Lagos','Abuja','Oyo','Rivers','Kano'])[1 + c.customer_id % 6],
       true
FROM customers c
WHERE c.customer_id > 3;

-- 200 vendors, 12 more categories, 5,000 products
INSERT INTO vendors (business_name, email, phone)
SELECT 'Vendor ' || g, 'vendor' || g || '@example.com', '070' || lpad(g::text, 8, '0')
FROM generate_series(1, 200) g;

INSERT INTO categories (name, description)
SELECT 'Category ' || g, 'Generated category ' || g
FROM generate_series(1, 12) g;

INSERT INTO products (category_id, name, description)
SELECT (1 + floor(random() * 15))::int, 'Product ' || g, 'Generated product ' || g
FROM generate_series(1, 5000) g;

-- 20,000 vendor offers (4 vendors per generated product)
INSERT INTO vendor_products (vendor_id, product_id, price, stock_quantity)
SELECT 4 + ((p.product_id + k * 50) % 200),
       p.product_id,
       round((1000 + random() * 199000)::numeric, 2),
       (random() * 500)::int
FROM products p
CROSS JOIN generate_series(0, 3) k
WHERE p.product_id > 4;

INSERT INTO delivery_agents (full_name, phone)
SELECT 'Agent ' || g, '081' || lpad(g::text, 8, '0')
FROM generate_series(1, 50) g;

-- 200,000 orders (4 per generated customer), spread over two years
INSERT INTO orders (customer_id, address_id, order_date, status, total_amount)
SELECT a.customer_id, a.address_id,
       now() - (random() * 730 || ' days')::interval,
       (ARRAY['pending','paid','shipped','delivered','cancelled'])[1 + floor(random() * 5)::int],
       0
FROM (SELECT customer_id, address_id FROM addresses WHERE customer_id > 3) a
CROSS JOIN generate_series(1, 4) g;

-- 400,000 order items (2 per order), priced from the vendor offer
INSERT INTO order_items (order_id, vendor_product_id, quantity, unit_price)
SELECT o.order_id, vp.vendor_product_id, 1 + floor(random() * 3)::int, vp.price
FROM orders o
CROSS JOIN generate_series(0, 1) k
JOIN vendor_products vp ON vp.vendor_product_id = 6 + ((o.order_id * 7 + k) % 20000)
WHERE o.order_id > 3;

UPDATE orders o
SET total_amount = s.total
FROM (SELECT order_id, sum(quantity * unit_price) AS total
      FROM order_items GROUP BY order_id) s
WHERE s.order_id = o.order_id AND o.order_id > 3;

-- successful payments for paid, shipped and delivered orders
INSERT INTO payments (order_id, method, amount, status, attempted_at, paid_at)
SELECT order_id,
       (ARRAY['card','bank_transfer','ussd','wallet'])[1 + floor(random() * 4)::int],
       total_amount, 'successful', order_date, order_date + interval '5 minutes'
FROM orders
WHERE order_id > 3 AND status IN ('paid','shipped','delivered') AND total_amount > 0;

-- one delivery per vendor for shipped and delivered orders
INSERT INTO deliveries (order_id, vendor_id, agent_id, status, shipped_at, delivered_at)
SELECT o.order_id, vp.vendor_id, 3 + floor(random() * 50)::int, o.status,
       o.order_date + interval '1 day',
       CASE WHEN o.status = 'delivered' THEN o.order_date + interval '3 days' END
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN vendor_products vp ON vp.vendor_product_id = oi.vendor_product_id
WHERE o.order_id > 3 AND o.status IN ('shipped','delivered')
GROUP BY o.order_id, vp.vendor_id, o.status, o.order_date;

-- reviews for about half of the delivered items
INSERT INTO reviews (customer_id, product_id, rating, comment)
SELECT o.customer_id, vp.product_id, 1 + floor(random() * 5)::int, 'Generated review'
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN vendor_products vp ON vp.vendor_product_id = oi.vendor_product_id
WHERE o.order_id > 3 AND o.status = 'delivered' AND random() < 0.5
ON CONFLICT (customer_id, product_id) DO NOTHING;

-- refresh the planner's statistics
ANALYZE;