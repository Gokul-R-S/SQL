
# Amazon Sales Analysis (SQL Project)

## Overview

This project showcases a **SQL-based analysis of an e-commerce platform**, addressing real-world business questions around revenue, customer behavior, inventory, seller performance, and logistics.
The focus is on **analytical SQL, clean data modeling, and performance-aware querying**.

---

## ERD

The database schema was designed using **draw.io**, covering customers, sellers, products, orders, inventory, payments, and shipping.

<img width="1051" height="850" alt="Image" src="https://github.com/user-attachments/assets/73121373-3f26-459a-9bbd-80885d3eb3ae" />

---

## Database Design

**8 normalized tables**:
`customers`, `sellers`, `products`, `orders`, `order_items`, `inventory`, `payments`, `shippings`

* Enforced PK/FK relationships
* Normalized for scalable analytics
* Optimized for joins and aggregations

---

## SQL Techniques Used

* CTEs and window functions (`RANK`, `ROW_NUMBER`)
* Conditional logic (`CASE`)
* Advanced aggregations
* Time-based analysis
* Query optimization using `EXPLAIN ANALYZE`

---

## Performance & Data Quality

* Indexed frequently joined and filtered columns
* Reduced execution time from ~30 ms to ~3–5 ms
* Removed duplicates, handled nulls, standardized statuses

---

## Business Questions Answered

* Which high-value customers are at risk of churn?
* Which categories and sellers underperform?
* Which high-margin products need restocking?
* How is revenue distributed across categories and shippers?
* Where do returns and shipping delays occur?

---

## Outcome

* Actionable business insights
* Efficient, production-style SQL queries
* Reusable analytics framework for e-commerce data

---

## Conclusion

This project demonstrates **practical, business-focused SQL analytics** with attention to **performance, clarity, and real-world applicability**.
