
# Amazon Sales Analysis (SQL Project)

---

## Overview

This project presents a **SQL-based analysis of an e-commerce platform**, designed to answer real-world business questions related to revenue, customer behavior, inventory management, seller performance, and logistics.

The focus is on **analytical SQL, performance-aware querying, and business insights** built on a normalized relational database.

---

## Entity Relationship Diagram (ERD)

The database schema was designed using **draw.io**, illustrating relationships between customers, sellers, products, orders, inventory, payments, and shipping data.

<img width="1051" height="850" alt="Image" src="https://github.com/user-attachments/assets/73121373-3f26-459a-9bbd-80885d3eb3ae" />

---

## Database Design

The database consists of **8 normalized tables**:

`customers`, `sellers`, `products`, `orders`, `order_items`, `inventory`, `payments`, `shippings`

Design highlights:

* Primary and foreign keys ensure data integrity
* Normalized structure supports scalable analytics
* Schema optimized for joins and aggregations

Schema creation scripts are included in the repository.

---

## Key SQL Techniques Used

* Common Table Expressions (CTEs)
* Window functions (`RANK`, `ROW_NUMBER`, `AVG OVER`)
* Conditional logic using `CASE`
* Advanced aggregations and filtering
* Time-based analysis using intervals and date arithmetic
* Query performance analysis using `EXPLAIN ANALYZE`

---

## Query Performance Considerations

Query performance was evaluated using `EXPLAIN ANALYZE` on frequently used analytical patterns.
After indexing commonly joined and filtered columns:

* Execution times improved significantly (e.g., ~30 ms to ~3–5 ms)
* Sequential scans were replaced with index scans
* Performance gains were consistent across analytical queries

This ensured efficient execution across the entire project.

---

## Data Cleaning

Data preparation focused on ensuring reliability and consistency:

* Removal of duplicate records
* Handling missing values in critical fields
* Standardization of categorical values (order and payment status)

Null handling was applied contextually (e.g., default placeholders for missing addresses, “Pending” for null payment status).

---

## Business Problems Addressed

The analysis focuses on answering questions such as:

1. Which high-value customers are at risk of churn?
2. Which product categories and sellers are underperforming?
3. Which fast-moving, high-margin products require restocking?
4. How is revenue distributed across categories and shipping providers?
5. Where do shipping delays occur most frequently?

---

## Outcomes

* Actionable insights for marketing, operations, and sales teams
* Efficient and readable analytical SQL queries
* Measurable query performance improvements
* A reusable SQL analytics framework for e-commerce datasets

---

## Conclusion

This project demonstrates the practical application of **advanced SQL analytics** to solve business-driven problems in an e-commerce environment, highlighting both **technical depth** and **business impact**.

