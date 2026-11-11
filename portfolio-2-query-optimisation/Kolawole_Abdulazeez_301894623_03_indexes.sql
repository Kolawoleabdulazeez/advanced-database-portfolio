-- Portfolio 2: indexes added after capturing the baseline execution plans

CREATE INDEX idx_orders_customer_id            ON orders (customer_id);              -- Q1
CREATE INDEX idx_order_items_vendor_product_id ON order_items (vendor_product_id);   -- Q2
CREATE INDEX idx_vendor_products_product_id    ON vendor_products (product_id);      -- Q3
CREATE INDEX idx_products_name                 ON products (name);                   -- Q3
CREATE INDEX idx_orders_order_date             ON orders (order_date);               -- Q4
CREATE INDEX idx_deliveries_vendor_status      ON deliveries (vendor_id, status);    -- Q5

ANALYZE;