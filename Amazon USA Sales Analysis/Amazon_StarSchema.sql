DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS dim_sellers;

-- Dim Customers
CREATE TABLE dim_customers
(
    customer_id  INT PRIMARY KEY,
    first_name   VARCHAR(20),
    last_name    VARCHAR(20),
    state        VARCHAR(20)
);

-- Dim Sellers
CREATE TABLE dim_sellers
(
    seller_id   INT PRIMARY KEY,
    seller_name VARCHAR(25),
    origin      VARCHAR(15)
);

-- Dim Products (flattened category + inventory)
CREATE TABLE dim_products
(
    product_id      INT PRIMARY KEY,
    product_name    VARCHAR(50),
    price           FLOAT,
    cogs            FLOAT,
    category_name   VARCHAR(20),
    stock           INT,
    warehouse_id    INT,
    last_stock_date DATE
);

-- Fact Orders (flattened order_items + payments + shippings)
CREATE TABLE fact_orders
(
    order_id           INT PRIMARY KEY,
    customer_id        INT,
    seller_id          INT,
    product_id         INT,
    order_date         DATE,
    order_status       VARCHAR(15),
    quantity           INT,
    price_per_unit     FLOAT,
    payment_date       DATE,
    payment_status     VARCHAR(20),
    shipping_date      DATE,
    return_date        DATE,
    shipping_providers VARCHAR(15),
    delivery_status    VARCHAR(15),
    CONSTRAINT fact_orders_fk_customers FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    CONSTRAINT fact_orders_fk_sellers   FOREIGN KEY (seller_id)   REFERENCES dim_sellers(seller_id),
    CONSTRAINT fact_orders_fk_products  FOREIGN KEY (product_id)  REFERENCES dim_products(product_id)
);

-- Import order:
-- 1. dim_customers
-- 2. dim_sellers
-- 3. dim_products
-- 4. fact_orders



-- 1. Foreign key join columns (used in EVERY query)
CREATE INDEX idx_fact_orders_customer_id ON fact_orders(customer_id);
CREATE INDEX idx_fact_orders_seller_id   ON fact_orders(seller_id);
CREATE INDEX idx_fact_orders_product_id  ON fact_orders(product_id);

-- 2. order_date 
CREATE INDEX idx_fact_orders_order_date ON fact_orders(order_date);

-- 3. order_status 
CREATE INDEX idx_fact_orders_order_status ON fact_orders(order_status);

-- 4. delivery_status 
CREATE INDEX idx_fact_orders_delivery_status ON fact_orders(delivery_status);