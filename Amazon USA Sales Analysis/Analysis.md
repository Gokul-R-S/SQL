# **Amazon Sales Analysis**

**Domain:** E-commerce

**Focus:** Revenue, Customer Retention, Inventory, Sellers, Logistics

This project contains a collection of real-world business questions solved using SQL.
Each section includes:

* Business context
* Analytical objective
* Expected insights

---

## Question 1: Identify At-Risk High-Value Customers for Retention

### Business Problem

The marketing team wants to launch a targeted retention campaign for high-value customers who may be at risk of churn.

### Objective

Identify customers who:

* Have spent more than **$5,000** in total (lifetime value)
* Have **not made a purchase in the last 90 days**

This allows the marketing team to proactively engage valuable customers before they churn completely.

### Expected Output

* Customer name and location
* Total lifetime spend
* Number of orders
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
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        c.state,
        c.address
)
SELECT
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

Management wants to understand which product categories contribute most to overall revenue.

### Objective

Calculate:

* Total revenue per category
* Percentage contribution of each category to total platform revenue

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

Regional performance analysis requires identifying weak product categories within each state.

### Objective

For each state:

* Identify the product category with the **lowest total sales**

### Expected Output

* State
* Least-selling category
* Total sales for that category

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

## Question 4: Reduce Product Returns to Improve Profitability

### Business Problem

Product returns are negatively impacting profit margins. The operations team needs to understand *why* returns are happening.

### Objective

Identify products that:

* Have a **return rate above 5%**
* Have generated **more than $10,000 in revenue**

Then determine whether returns are primarily driven by:

* Seller quality issues
* Shipping or handling problems

### Expected Output

* Product and category details
* Return rate
* Revenue and cost impact of returns
* Primary return cause
* Seller or shipping provider to investigate
* Recommended action

```sql
WITH product_orders AS (
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        o.order_id,
        o.seller_id,
        s_info.seller_name,
        sh.shipping_providers,
        sh.delivery_status,
        oi.price_per_unit * oi.quantity AS order_value,
        p.cogs * oi.quantity AS order_cost,
        (sh.delivery_status = 'Returned')::int AS is_returned
    FROM products p
    JOIN order_items oi USING (product_id)
    JOIN orders o USING (order_id)
    JOIN category c USING (category_id)
    LEFT JOIN sellers s_info USING (seller_id)
    LEFT JOIN shippings sh USING (order_id)
    WHERE o.order_status <> 'Cancelled'
),
product_metrics AS (
    SELECT
        product_id,
        product_name,
        category_name,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(is_returned) AS total_returns,
        SUM(order_value) AS total_revenue,
        SUM(order_value) FILTER (WHERE is_returned = 1) AS revenue_lost_to_returns,
        SUM(order_cost) FILTER (WHERE is_returned = 1) AS cost_of_returns,
        ROUND(
            (SUM(is_returned)::DECIMAL / COUNT(DISTINCT order_id)) * 100,
            2
        ) AS return_rate_pct
    FROM product_orders
    GROUP BY product_id, product_name, category_name
),
seller_return_analysis AS (
    SELECT
        product_id,
        seller_id,
        seller_name,
        COUNT(DISTINCT order_id) AS seller_orders,
        SUM(is_returned) AS seller_returns,
        ROUND(
            SUM(is_returned)::DECIMAL / NULLIF(COUNT(DISTINCT order_id), 0) * 100,
            2
        ) AS seller_return_rate,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY SUM(is_returned) DESC
        ) AS seller_rank
    FROM product_orders
    GROUP BY product_id, seller_id, seller_name
    HAVING COUNT(DISTINCT order_id) >= 5
),
shipping_return_analysis AS (
    SELECT
        product_id,
        shipping_providers,
        COUNT(DISTINCT order_id) AS provider_orders,
        SUM(is_returned) AS provider_returns,
        ROUND(
            SUM(is_returned)::DECIMAL / NULLIF(COUNT(DISTINCT order_id), 0) * 100,
            2
        ) AS provider_return_rate,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY SUM(is_returned) DESC
        ) AS provider_rank
    FROM product_orders
    WHERE shipping_providers IS NOT NULL
    GROUP BY product_id, shipping_providers
    HAVING COUNT(DISTINCT order_id) >= 5
)
SELECT
    pm.product_id,
    pm.product_name,
    pm.category_name,
    pm.total_orders,
    pm.total_returns,
    pm.return_rate_pct,
    ROUND(pm.total_revenue, 2) AS total_revenue,
    ROUND(pm.revenue_lost_to_returns, 2) AS revenue_lost_to_returns,
    ROUND(pm.cost_of_returns, 2) AS cost_of_returns,
    ROUND(
        pm.revenue_lost_to_returns + pm.cost_of_returns,
        2
    ) AS total_return_impact,
    sra.seller_name AS top_return_seller,
    sha.shipping_providers AS top_return_provider,
    CASE
        WHEN sra.seller_return_rate > sha.provider_return_rate * 1.5
            THEN 'Seller Quality Issue'
        WHEN sha.provider_return_rate > sra.seller_return_rate * 1.5
            THEN 'Shipping / Handling Issue'
        ELSE 'Mixed Factors'
    END AS primary_return_cause
FROM product_metrics pm
LEFT JOIN seller_return_analysis sra
    ON pm.product_id = sra.product_id
   AND sra.seller_rank = 1
LEFT JOIN shipping_return_analysis sha
    ON pm.product_id = sha.product_id
   AND sha.provider_rank = 1
WHERE pm.return_rate_pct > 5
  AND pm.total_revenue > 10000
ORDER BY total_return_impact DESC;
```

---

## Question 5: Top 10 Products with Highest Revenue Decline (2022 vs 2023)

### Business Problem

Finance wants to identify products with significant revenue decline year-over-year.

### Objective

Compare product revenue between 2022 and 2023 and rank products by revenue decrease percentage.

### Expected Output

* Product name
* Category
* Revenue in 2022
* Revenue in 2023
* Percentage decrease

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
  WHERE EXTRACT(YEAR FROM o.order_date) IN (2022, 2023)
  GROUP BY p.product_id, p.product_name, c.category_name, yr
),
ranked_products AS (
  SELECT
    curr.product_id,
    curr.product_name,
    curr.category_name,
    prev.revenue AS revenue_2022,
    curr.revenue AS revenue_2023,
	ROUND((curr.revenue - prev.revenue)::numeric / prev.revenue * 100, 2) AS revenue_decrease_ratio,
	RANK() OVER (ORDER BY (curr.revenue - prev.revenue) / prev.revenue) AS rnk
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

High return rates often signal quality or expectation issues.

### Objective

Identify the top 10 products with the highest return percentage relative to total sales.

### Expected Output

* Product name
* Return percentage

```sql
WITH cte AS (
    SELECT 
        product_id,
        product_name,
        ROUND( COUNT(*) FILTER (WHERE order_status = 'Returned')::decimal / COUNT(*) * 100,2 ) AS return_pct,
        RANK() OVER ( ORDER BY COUNT(*) FILTER (WHERE order_status = 'Returned')::decimal / COUNT(*) DESC ) AS rnk
    FROM order_items
    JOIN products USING (product_id)
    JOIN orders USING (order_id)
    GROUP BY product_id, product_name )
SELECT product_name, return_pct
FROM cte
WHERE rnk <= 10;
```

---

## Question 7: Inactive Sellers

### Business Problem

The marketplace team needs to identify sellers who are no longer active.

### Objective

Find sellers who:

* Have made **no sales in the last 6 months**

### Expected Output

* Seller name
* Last sale date
* Total historical sales

```sql
WITH inactive_sellers AS (
    SELECT seller_id, seller_name
    FROM sellers s 
    WHERE NOT EXISTS (
        SELECT 1 
        FROM orders o 
        WHERE o.seller_id = s.seller_id 
        AND o.order_date >= CURRENT_DATE - INTERVAL '6 months') )
SELECT  
    ins.seller_name,
    COALESCE(MAX(o.order_date)::text, 'No sales ever') AS last_sale_date,
    COALESCE(SUM(oi.total_sale), 0) AS total_sales
FROM inactive_sellers ins
LEFT JOIN orders o ON o.seller_id = ins.seller_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY ins.seller_id, ins.seller_name
ORDER BY MAX(o.order_date) DESC NULLS LAST;
```

---

## Question 8: Optimize Inventory for Fast-Moving, High-Margin Products

### Business Problem

Stockouts on high-performing products reduce revenue and customer satisfaction.

### Objective

Identify products that:

* Sold **50+ units in the last 6 months**
* Have **profit margins above 40%**
* Have **less than 30 days of inventory remaining**

### Expected Output

* Product details
* Sales velocity
* Inventory coverage
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
        COUNT(DISTINCT o.order_id) AS num_orders,
        SUM(oi.quantity) AS units_sold_6months,
        SUM(oi.quantity * oi.price_per_unit) AS revenue_6months,
        COALESCE(i.stock, 0) AS current_stock
    FROM products p
    JOIN order_items oi
        USING (product_id)
    JOIN orders o
        USING (order_id)
    JOIN category c
        USING (category_id)
    LEFT JOIN inventory i
        USING (product_id)
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '6 months'
      AND o.order_status <> 'Cancelled'
    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name,
        p.price,
        p.cogs,
        i.stock )
SELECT
    product_id,
    product_name,
    category_name,
    profit_margin_pct,
    units_sold_6months,
    ROUND(revenue_6months, 2) AS revenue_6months,
    current_stock,
    ROUND(units_sold_6months / 180.0, 2) AS daily_sales_velocity,
    ROUND(current_stock / NULLIF(units_sold_6months / 180.0, 0), 1) AS days_of_inventory_left,
    CASE
        WHEN current_stock / NULLIF(units_sold_6months / 180.0, 0) < 15 THEN 'URGENT - Restock Now'
        WHEN current_stock / NULLIF(units_sold_6months / 180.0, 0) BETWEEN 15 AND 30 THEN 'Restock Soon'
    END AS replenishment_priority
FROM recent_sales
WHERE units_sold_6months >= 50 -- High demand
  AND profit_margin_pct > 40  -- Good margins
  AND current_stock / NULLIF(units_sold_6months / 180.0, 0) < 30 -- Low stock
ORDER BY
    days_of_inventory_left ASC,
    revenue_6months DESC;
```

---

## Question 9: Revenue by Shipping Provider

### Business Problem

Operations wants to evaluate shipping partners based on volume and efficiency.

### Objective

Calculate:

* Total revenue handled
* Number of orders shipped
* Average time to ship

```sql
SELECT 
    shipping_providers,
    COUNT(o.order_id) AS orders_handled,
    ROUND(SUM(total_sale), 2) AS total_revenue,
    ROUND(AVG(s.shipping_date - o.order_date), 2) AS avg_days_to_ship
FROM orders o
JOIN order_items oi USING(order_id)
JOIN shippings s USING(order_id)
GROUP BY shipping_providers
ORDER BY total_revenue DESC;
```


---

## Question 10: Identify Underperforming Sellers to Improve Product Mix

### Business Problem

Some sellers generate high order volumes but low revenue due to low-value product focus.

### Objective

Identify sellers who:

* Have **100+ orders**
* Have an **average order value below $300**

Then recommend higher-value product categories they should focus on.

### Expected Output

* Seller performance metrics
* Revenue opportunity
* Recommended high-value categories

```sql
WITH seller_performance AS (
    SELECT
        s.seller_id,
        s.seller_name,
        s.origin,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.total_sale) AS total_revenue,
        ROUND(AVG(oi.total_sale), 2) AS avg_order_value
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
        ROUND(AVG(oi.total_sale), 2) AS platform_avg_order_value
    FROM order_items oi
    JOIN orders o
        USING (order_id)
    WHERE o.order_status <> 'Cancelled'
),
high_value_categories AS (
    SELECT
        c.category_id,
        c.category_name,
        ROUND(AVG(oi.total_sale), 2) AS category_avg_order_value,
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
    HAVING AVG(oi.total_sale) > 500), -- Only high-value categories
seller_category_performance AS (
    SELECT
        s.seller_id,
        c.category_name,
        SUM(oi.total_sale) AS category_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY s.seller_id
            ORDER BY SUM(oi.total_sale) DESC
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
WHERE sp.total_orders >= 100 -- Exclude low-volume sellers
  AND sp.avg_order_value < 300 -- Filter for underperforming sellers
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
```
