INSERT INTO customers (full_name, email, phone, password_hash) VALUES
('Amina Yusuf',    'amina.yusuf@example.com',    '08031234567', 'placeholder_hash_1'),
('Chinedu Okafor', 'chinedu.okafor@example.com', '08052345678', 'placeholder_hash_2'),
('Tolu Adeyemi',   'tolu.adeyemi@example.com',   '08093456789', 'placeholder_hash_3');

INSERT INTO addresses (customer_id, street, city, state, is_default) VALUES
(1, '12 Allen Avenue',   'Ikeja', 'Lagos', true),
(2, '5 Garki Road',      'Garki', 'Abuja', true),
(3, '22 Ring Road',      'Ibadan', 'Oyo',  true),
(1, '3 Admiralty Way',   'Lekki', 'Lagos', false);

INSERT INTO vendors (business_name, email, phone) VALUES
('TechHub Nigeria',  'sales@techhub.example',  '08011111111'),
('StyleHouse Lagos', 'hello@stylehouse.example', '08022222222'),
('HomeNest Stores',  'info@homenest.example',  '08033333333');

INSERT INTO categories (name, description) VALUES
('Electronics',    'Phones, audio and gadgets'),
('Fashion',        'Clothing and accessories'),
('Home & Kitchen', 'Household and cooking items');

INSERT INTO products (category_id, name, description) VALUES
(1, 'Samsung Galaxy A15 Phone', 'Android smartphone'),
(1, 'Wireless Earbuds',         'Bluetooth earbuds'),
(2, 'Ankara Dress',             'Handmade Ankara fabric dress'),
(3, 'Non-stick Frying Pan',     '28cm frying pan');

INSERT INTO vendor_products (vendor_id, product_id, price, stock_quantity) VALUES
(1, 1, 185000.00, 25),
(1, 2,  15000.00, 60),
(2, 3,  22000.00, 40),
(3, 4,  12500.00, 30),
(3, 2,  16500.00, 10);

INSERT INTO delivery_agents (full_name, phone) VALUES
('Musa Ibrahim', '08144444444'),
('Grace Eze',    '08155555555');

INSERT INTO orders (customer_id, address_id, status, total_amount) VALUES
(1, 1, 'paid',    215000.00),
(2, 2, 'pending',  34500.00),
(3, 3, 'pending',  16500.00);

INSERT INTO order_items (order_id, vendor_product_id, quantity, unit_price) VALUES
(1, 1, 1, 185000.00),
(1, 2, 2,  15000.00),
(2, 3, 1,  22000.00),
(2, 4, 1,  12500.00),
(3, 5, 1,  16500.00);

INSERT INTO payments (order_id, method, amount, status, paid_at) VALUES
(1, 'card',          215000.00, 'failed',     NULL),
(1, 'bank_transfer', 215000.00, 'successful', now()),
(2, 'ussd',           34500.00, 'pending',    NULL);

INSERT INTO deliveries (order_id, vendor_id, agent_id, status, shipped_at) VALUES
(1, 1, 1,    'shipped',    now()),
(2, 2, NULL, 'processing', NULL),
(2, 3, NULL, 'processing', NULL);

INSERT INTO reviews (customer_id, product_id, rating, comment) VALUES
(1, 1, 5, 'Great phone, fast delivery'),
(2, 3, 4, 'Lovely fabric');