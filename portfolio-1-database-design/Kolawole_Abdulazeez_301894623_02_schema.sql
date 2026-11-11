-- Shoptackles: multi-vendor e-commerce schema (PostgreSQL 17)

CREATE TABLE customers (
    customer_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    phone          VARCHAR(20),
    password_hash  VARCHAR(255)  NOT NULL,
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE TABLE addresses (
    address_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  INT NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    street       VARCHAR(200) NOT NULL,
    city         VARCHAR(80)  NOT NULL,
    state        VARCHAR(80)  NOT NULL,
    is_default   BOOLEAN      NOT NULL DEFAULT false
);

-- At most one default address per customer
CREATE UNIQUE INDEX uq_one_default_address_per_customer
    ON addresses (customer_id) WHERE is_default;

CREATE TABLE vendors (
    vendor_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    business_name  VARCHAR(150) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    phone          VARCHAR(20),
    status         VARCHAR(20)  NOT NULL DEFAULT 'active'
                   CHECK (status IN ('active', 'suspended', 'closed')),
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE categories (
    category_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE,
    description  TEXT
);

CREATE TABLE products (
    product_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id  INT NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    name         VARCHAR(200) NOT NULL,
    description  TEXT,
    is_active    BOOLEAN      NOT NULL DEFAULT true,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- Junction table: vendors <-> products
CREATE TABLE vendor_products (
    vendor_product_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vendor_id          INT NOT NULL REFERENCES vendors(vendor_id)   ON DELETE RESTRICT,
    product_id         INT NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    price              NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    stock_quantity     INT           NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active          BOOLEAN       NOT NULL DEFAULT true,
    UNIQUE (vendor_id, product_id)
);

CREATE TABLE delivery_agents (
    agent_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    phone      VARCHAR(20),
    status     VARCHAR(20)  NOT NULL DEFAULT 'available'
               CHECK (status IN ('available', 'busy', 'offline')),
    is_active  BOOLEAN      NOT NULL DEFAULT true
);

CREATE TABLE orders (
    order_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    address_id    INT NOT NULL REFERENCES addresses(address_id)  ON DELETE RESTRICT,
    order_date    TIMESTAMPTZ   NOT NULL DEFAULT now(),
    status        VARCHAR(20)   NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled')),
    total_amount  NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0)
);

-- Junction table: orders <-> vendor_products
CREATE TABLE order_items (
    order_item_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id           INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    vendor_product_id  INT NOT NULL REFERENCES vendor_products(vendor_product_id) ON DELETE RESTRICT,
    quantity           INT           NOT NULL CHECK (quantity > 0),
    unit_price         NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    UNIQUE (order_id, vendor_product_id)
);

CREATE TABLE payments (
    payment_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES orders(order_id) ON DELETE RESTRICT,
    method        VARCHAR(30)   NOT NULL
                  CHECK (method IN ('card', 'bank_transfer', 'ussd', 'wallet')),
    amount        NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    status        VARCHAR(20)   NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'failed', 'successful')),
    attempted_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),
    paid_at       TIMESTAMPTZ,
    -- paid_at is filled if and only if the payment succeeded
    CHECK ((status = 'successful') = (paid_at IS NOT NULL))
);

-- Business rule: at most one successful payment per order
CREATE UNIQUE INDEX uq_one_successful_payment_per_order
    ON payments (order_id) WHERE status = 'successful';

CREATE TABLE deliveries (
    delivery_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES orders(order_id)   ON DELETE RESTRICT,
    vendor_id     INT NOT NULL REFERENCES vendors(vendor_id) ON DELETE RESTRICT,
    agent_id      INT REFERENCES delivery_agents(agent_id)   ON DELETE SET NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'processing'
                  CHECK (status IN ('processing', 'shipped', 'delivered', 'failed')),
    shipped_at    TIMESTAMPTZ,
    delivered_at  TIMESTAMPTZ,
    UNIQUE (order_id, vendor_id),
    CHECK (delivered_at IS NULL OR shipped_at IS NULL OR delivered_at >= shipped_at)
);

-- Junction table: customers <-> products
CREATE TABLE reviews (
    review_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  INT NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    product_id   INT NOT NULL REFERENCES products(product_id)   ON DELETE RESTRICT,
    rating       INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment      TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (customer_id, product_id)
);