# Customer Activity Insights

This project analyzes customer activity, sleep, and weight data using PostgreSQL to extract actionable insights and improve customer engagement.

---

## Overview

The analysis reveals key insights such as the most and least active days of the week (Tuesday and Sunday), the customer with the most effective sleep (7007744171), and the identification of 9 customers without sleep records. It also highlights 6 customers with complete data across activity, sleep, and weight logs. Additionally, it aggregates total sleep hours by day, identifies weight extremes, and calculates the day with the most sleep (Wednesday). The project further examines the percentage of time spent in bed without sleeping, with Sunday having the highest percentage. Wednesday is found to be the most frequently mentioned day across all datasets, and average kilometers walked by customers with more than 6000 steps are calculated.

---

## Key Features
- Advanced analysis using CTEs, window functions, and aggregations.
- Efficient handling of missing data for comprehensive insights.

---

## Technology Stack
- **Database:** PostgreSQL
- **Language:** SQL

---

## How to Use
1. Import datasets (`daily_activity`, `sleep_day`, `weight_log`) into PostgreSQL.
2. Execute the provided SQL queries to generate insights.

---

## Insights Summary
This project identifies key patterns in activity, sleep, and weight data to optimize customer health and engagement strategies.