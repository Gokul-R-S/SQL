# Bellabeat Fitness Tracker - SQL Analysis  

## Overview 
PostgreSQL analysis of customer activity, sleep, and weight data to extract actionable insights for improving customer engagement and health outcomes.

---

## Key Insights  

• **Peak Activity Patterns**: Tuesday emerges as the highest engagement day with 1.24M total steps, while Sunday shows 32% lower activity levels, indicating mid-week motivation peaks that could inform targeted intervention strategies.

• **Sleep Optimization Opportunities**: 27% of users lack sleep tracking data entirely, while Wednesday demonstrates optimal sleep efficiency with only 7.52% of bed-time spent awake, suggesting potential for sleep coaching programs focused on replicating Wednesday patterns.

• **Data Completeness Challenge**: Only 6 customers maintain complete activity, sleep, and weight records across all tracking categories, highlighting a need to improve user tracking consistency or device syncing.

• **Weekend Recovery Patterns**: Sunday shows the highest percentage (10.08%) of restless bed-time, indicating weekend sleep quality deterioration that contrasts with Wednesday's peak sleep efficiency, revealing weekly rhythm disruptions.

• **Activity-Distance Correlation**: Users average 4.24 km per 6,000 steps, establishing a reliable baseline for distance-based goal setting and progress tracking in fitness applications.

• **Comprehensive Tracking Adoption**: Wednesday appears most frequently across all data categories, suggesting mid-week represents peak user engagement periods when intervention strategies would be most effective.

---

## Technologies Used

**PostgreSQL** (SQL queries, CTEs, aggregations, SQL Window Functions)

---

## Datasets
- `daily_activity` - Steps, distance, calories
- `sleep_day` - Sleep duration and quality  
- `weight_log` - Weight and BMI tracking

---

## Usage
1. Import datasets into PostgreSQL
2. Execute SQL queries to generate insights
3. Apply findings to optimize engagement strategies

---

## Outcome
Data-driven insights for improving fitness tracking user experience and health outcomes through behavioral pattern analysis.
