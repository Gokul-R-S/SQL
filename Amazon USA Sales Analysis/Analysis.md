# **Amazon Sales Analysis**

**Domain:** E-commerce
**Focus:** Revenue, Customer Retention, Inventory, Sellers, Logistics

This project contains a collection of real-world business questions solved using SQL.
Each section includes:

* Business context
* Analytical objective
* Expected insights
* Well-formatted SQL queries

---

## Question 1: Identify At-Risk High-Value Customers for Retention

### Business Problem

The marketing team wants to launch a targeted retention campaign for **high-value customers who are showing signs of churn**.

### Objective

Identify customers who:

* Have spent more than **$5,000 lifetime**
* Have **not made a purchase in the last 90 days**

These customers are valuable but at risk and should be prioritized for personalized retention offers.

### Expected Output

* Customer ID and name
* State
* Total number of orders
* Lifetime value
* Last order date
* Days since last purchase
* Churn risk classification

```sql
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.state,
        c.address,
        COUNT(o.order_id) AS total_orders,
        SUM(oi.total_sale) AS lifetime_value,
        MAX(o.order_date) AS last_order_date,
        CURRENT_DATE - MAX(o.order_date) AS days_since_last_order
    FROM customers c
    JOIN orders o USING (customer_id)
    JOIN order_items oi USING (order_id)
    WHERE o.order_status != 'Cancelled'
    GROUP BY 
        c.customer_id, 
        c.first_name, 
        c.last_name, 
        c.state, 
        c.address
)
SELECT
    customer_id,
    customer_name,
    state,
    total_orders,
    ROUND(lifetime_value, 2) AS lifetime_value,
    last_order_date,
    days_since_last_order,
    CASE
        WHEN days_since_last_order BETWEEN 90 AND 120 THEN 'Medium Risk'
        WHEN days_since_last_order > 120 THEN 'High Risk'
    END AS churn_risk_level
FROM customer_spending
WHERE lifetime_value > 5000
  AND days_since_last_order >= 90
ORDER BY 
    lifetime_value DESC,
    days_since_last_order DESC;
```

---

## Question 2: Revenue Contribution by Product Category

### Business Problem

Leadership wants to understand which product categories drive the most revenue.

### Objective

Calculate:

* Total revenue per category
* Percentage contribution of each category to overall revenue

### Expected Output

* Category name
* Revenue contribution percentage

```sql
SELECT 
    category_name,
    ROUND(
        SUM(total_sale) / SUM(SUM(total_sale)) OVER () * 100, 
        2
    ) AS contribution_pct
FROM order_items oi
JOIN products USING (product_id)
JOIN category USING (category_id)
GROUP BY category_name
ORDER BY contribution_pct DESC;
```

---

## Question 3: Least-Selling Product Category by State

### Business Problem

Regional managers want to identify weak product performance across states.

### Objective

For each state, find the **least-selling product category** based on total sales.

### Expected Output

* State
* Category name
* Total sales

```sql
WITH cte AS (
    SELECT
        c.state,
        cat.category_name,
        SUM(oi.total_sale) AS total_sale,
        RANK() OVER (
            PARTITION BY c.state 
            ORDER BY SUM(oi.total_sale) ASC
        ) AS rnk
    FROM orders o
    JOIN customers c USING (customer_id)
    JOIN order_items oi USING (order_id)
    JOIN products p USING (product_id)
    JOIN category cat USING (category_id)
    GROUP BY c.state, cat.category_name
)
SELECT 
    state,
    category_name,
    total_sale
FROM cte
WHERE rnk = 1;
```

---

## Question 4: Identify Shipping Delays

### Business Problem

Delayed shipments negatively impact customer satisfaction.

### Objective

Identify orders where shipping occurred **more than 3 days after order placement**.

### Expected Output

* Customer details
* Order details
* Shipping provider
* Days taken to ship

```sql
SELECT 
    c.*,
    o.*,
    s.shipping_providers,
    s.shipping_date - o.order_date AS days_took_to_ship
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN shippings s ON o.order_id = s.order_id
WHERE s.shipping_date - o.order_date > 3;
```

---

## Question 5: Top 10 Products with Highest Revenue Decline (2022 vs 2023)

### Business Problem

Product managers want to identify products with sharp revenue drops year-over-year.

### Objective

Compare revenue between **2022 and 2023** and rank products with the highest decline.

### Expected Output

* Product name
* Category
* Revenue in 2022
* Revenue in 2023
* Revenue decrease percentage

```sql
WITH yearly_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        EXTRACT(YEAR FROM o.order_date) AS yr,
        SUM(oi.total_sale) AS revenue
    FROM orders o
    JOIN order_items oi USING (order_id)
    JOIN products p USING (product_id)
    JOIN category c USING (category_id)
    GROUP BY p.product_id, p.product_name, c.category_name, yr
),
ranked_products AS (
    SELECT
        curr.product_id,
        curr.product_name,
        curr.category_name,
        prev.revenue AS revenue_2022,
        curr.revenue AS revenue_2023,
        ROUND(
            (curr.revenue - prev.revenue)::numeric / prev.revenue * 100,
            2
        ) AS revenue_decrease_ratio,
        RANK() OVER (
            ORDER BY (curr.revenue - prev.revenue) / prev.revenue
        ) AS rnk
    FROM yearly_revenue curr
    JOIN yearly_revenue prev USING (product_id)
    WHERE prev.yr = 2022
      AND curr.yr = 2023
      AND curr.revenue < prev.revenue
)
SELECT
    product_name,
    category_name,
    revenue_2022,
    revenue_2023,
    revenue_decrease_ratio
FROM ranked_products
WHERE rnk <= 10;
```

---

## Question 6: Most Returned Products

### Business Problem

High return rates indicate product quality or expectation issues.

### Objective

Identify the **top 10 products with the highest return percentage**.

### Expected Output

* Product name
* Return percentage

```sql
WITH cte AS (
    SELECT 
        product_id,
        product_name,
        ROUND(
            COUNT(*) FILTER (WHERE order_status = 'Returned')::decimal 
            / COUNT(*) * 100,
            2
        ) AS return_pct,
        RANK() OVER (
            ORDER BY 
            COUNT(*) FILTER (WHERE order_status = 'Returned')::decimal 
            / COUNT(*) * 100 DESC
        ) AS rnk
    FROM order_items
    JOIN products USING (product_id)
    JOIN orders USING (order_id)
    GROUP BY product_id, product_name
)
SELECT
    product_name,
    return_pct
FROM cte
WHERE rnk <= 10;
```

---

## Question 7: Inactive Sellers

### Business Problem

Inactive sellers reduce marketplace efficiency.

### Objective

Identify sellers who have **not made any sales in the last 6 months**.

### Expected Output

* Seller name
* Last sale date
* Total sales

```sql
WITH cte AS (
    SELECT *
    FROM sellers s
    WHERE NOT EXISTS (
        SELECT 1
        FROM orders o
        WHERE o.seller_id = s.seller_id
          AND order_date >= CURRENT_DATE - INTERVAL '6 months'
    )
)
SELECT  
    seller_name,
    COALESCE(MAX(order_date)::text, 'No sales ever') AS last_sale_date,
    COALESCE(SUM(total_sale), 0) AS total_sales
FROM cte
LEFT JOIN orders USING (seller_id)
LEFT JOIN order_items USING (order_id)
GROUP BY seller_id, seller_name
ORDER BY MAX(order_date) DESC NULLS LAST;
```

---

## Question 8: Optimize Inventory for Fast-Moving, High-Margin Products

### Business Problem

Operations teams need to prevent stockouts of profitable, fast-selling products.

### Objective

Identify products that:

* Sold **50+ units in the last 6 months**
* Have **profit margin > 40%**
* Have **less than 30 days of inventory remaining**

### Expected Output

* Product details
* Profit margin
* Sales velocity
* Days of inventory remaining
* Replenishment priority

```sql
WITH recent_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        p.price,
        p.cogs,
        ROUND(((p.price - p.cogs) / p.price) * 100, 2) AS profit_margin_pct,
        SUM(oi.quantity) AS units_sold_6months,
        SUM(oi.quantity * oi.price_per_unit) AS revenue_6months,
        COALESCE(i.stock, 0) AS current_stock
    FROM products p
    JOIN order_items oi USING (product_id)
    JOIN orders o USING (order_id)
    JOIN category c USING (category_id)
    LEFT JOIN inventory i USING (product_id)
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '6 months'
      AND o.order_status <> 'Cancelled'
    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name,
        p.price,
        p.cogs,
        i.stock
)
SELECT
    product_id,
    product_name,
    category_name,
    profit_margin_pct,
    units_sold_6months,
    ROUND(revenue_6months, 2) AS revenue_6months,
    current_stock,
    ROUND(units_sold_6months / 180.0, 2) AS daily_sales_velocity,
    ROUND(
        current_stock / NULLIF(units_sold_6months / 180.0, 0),
        1
    ) AS days_of_inventory_left,
    CASE
        WHEN current_stock / NULLIF(units_sold_6months / 180.0, 0) < 15
            THEN 'URGENT - Restock Now'
        WHEN current_stock / NULLIF(units_sold_6months / 180.0, 0) BETWEEN 15 AND 30
            THEN 'Restock Soon'
    END AS replenishment_priority
FROM recent_sales
WHERE units_sold_6months >= 50
  AND profit_margin_pct > 40
  AND current_stock / NULLIF(units_sold_6months / 180.0, 0) < 30
ORDER BY
    days_of_inventory_left ASC,
    revenue_6months DESC;
```

---

## Question 9: Revenue by Shipping Provider

### Business Problem

Logistics teams want visibility into shipping partner performance.

### Objective

Calculate revenue handled by each shipping provider along with shipping efficiency.

### Expected Output

* Shipping provider
* Total orders handled
* Total revenue
* Average shipping time

```sql
SELECT 
    shipping_providers,
    COUNT(o.order_id) AS orders_handled,
    ROUND(SUM(total_sale), 2) AS total_revenue,
    ROUND(AVG(s.shipping_date - o.order_date), 2) AS avg_days_to_ship
FROM orders o
JOIN order_items oi USING (order_id)
JOIN shippings s USING (order_id)
GROUP BY shipping_providers
ORDER BY total_revenue DESC;
```

---

## Question 10: Identify Underperforming Sellers

### Business Problem

Some sellers generate high order volume but low revenue per order.

### Objective

Identify sellers with:

* **100+ orders**
* **Average order value < $300**

Then recommend **high-value product categories** they should focus on.

### Expected Output

* Seller performance metrics
* Revenue gap vs platform average
* Revenue opportunity
* Recommended high-value categories

```sql
WITH seller_performance AS (
    SELECT
        s.seller_id,
        s.seller_name,
        s.origin,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.price_per_unit) AS total_revenue,
        ROUND(AVG(oi.quantity * oi.price_per_unit), 2) AS avg_order_value
    FROM sellers s
    JOIN orders o
        USING (seller_id)
    JOIN order_items oi
        USING (order_id)
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        s.seller_id,
        s.seller_name,
        s.origin
),
platform_avg AS (
    SELECT
        ROUND(AVG(oi.quantity * oi.price_per_unit), 2) AS platform_avg_order_value
    FROM order_items oi
    JOIN orders o
        USING (order_id)
    WHERE o.order_status <> 'Cancelled'
),
high_value_categories AS (
    SELECT
        c.category_id,
        c.category_name,
        ROUND(AVG(oi.quantity * oi.price_per_unit), 2) AS category_avg_order_value,
        COUNT(DISTINCT oi.order_id) AS category_total_orders
    FROM category c
    JOIN products p
        USING (category_id)
    JOIN order_items oi
        USING (product_id)
    JOIN orders o
        USING (order_id)
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        c.category_id,
        c.category_name
    HAVING AVG(oi.quantity * oi.price_per_unit) > 500),
seller_category_performance AS (
    SELECT
        s.seller_id,
        c.category_name,
        SUM(oi.quantity * oi.price_per_unit) AS category_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY s.seller_id
            ORDER BY SUM(oi.quantity * oi.price_per_unit) DESC
        ) AS category_rank
    FROM sellers s
    JOIN orders o
        USING (seller_id)
    JOIN order_items oi
        USING (order_id)
    JOIN products p
        USING (product_id)
    JOIN category c
        USING (category_id)
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        s.seller_id,
        c.category_name)
SELECT
    sp.seller_id,
    sp.seller_name,
    sp.origin,
    sp.total_orders,
    ROUND(sp.total_revenue, 2) AS current_revenue,
    sp.avg_order_value AS current_avg_order_value,
    pa.platform_avg_order_value,
    ROUND(sp.avg_order_value - pa.platform_avg_order_value, 2) AS performance_gap,
    ROUND((pa.platform_avg_order_value - sp.avg_order_value) * sp.total_orders, 2) AS revenue_opportunity,
    scp.category_name AS current_best_category,
    ROUND(scp.category_revenue, 2) AS best_category_revenue,
    STRING_AGG(
        hvc.category_name,
        ', '
        ORDER BY hvc.category_avg_order_value DESC
    ) AS recommended_high_value_categories
FROM seller_performance sp
CROSS JOIN platform_avg pa
LEFT JOIN seller_category_performance scp
    ON sp.seller_id = scp.seller_id
   AND scp.category_rank = 1
LEFT JOIN high_value_categories hvc
    ON 1 = 1
WHERE sp.total_orders >= 100
  AND sp.avg_order_value < 300
GROUP BY
    sp.seller_id,
    sp.seller_name,
    sp.origin,
    sp.total_orders,
    sp.total_revenue,
    sp.avg_order_value,
    pa.platform_avg_order_value,
    scp.category_name,
    scp.category_revenue
ORDER BY
    revenue_opportunity DESC
LIMIT 15;
```

