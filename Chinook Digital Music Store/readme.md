# Chinook Digital Music Store - SQL Analysis  

## Overview 
PostgreSQL analysis of the Chinook Digital Music Store database to extract business insights on customer behavior, sales performance, and inventory optimization across 11 interconnected tables.

---

## Key Insights  

**1. Geographic Revenue Strategy**

The USA dominates in transaction volume (91 invoices), while Prague generates the highest per-city revenue (\$90.24). Focus on scaling operations in the US while replicating Prague’s **high-value customer acquisition model** through localized pricing and premium promotions.

**2. Genre Demand & Targeted Marketing**

Rock is the most purchased genre (835 purchases), with São Paulo having the largest rock consumer base (40 customers). Leverage this by designing **genre-specific promotions, playlists, and bundles**, and run **geo-targeted campaigns** in São Paulo, Berlin, and Paris to maximize engagement and revenue.

**3. Catalog Optimization**

43% of tracks (1,518 songs) were never purchased, creating digital “dead stock.” Streamline the catalog by **removing low-demand tracks, renegotiating licenses, or bundling them with popular content** to improve overall catalog profitability and user satisfaction.

**4. Customer Segmentation & Loyalty Programs**

Top spenders, like Helena Holý (\$49.62), indicate the presence of **premium-price buyers across 27 cities**. Launch **VIP programs, loyalty rewards, and premium pricing tiers** to retain high-value customers and incentivize repeat purchases.

**5. Artist Partnership Strategy**

Iron Maiden has the most content (213 tracks, 21 albums), and 50 artists span multiple genres. Build **exclusive digital partnerships with high-output artists** and **cross-promote versatile artists** to drive discovery and cross-genre sales.

**6. Sales Team Performance & Training**

Jane Peacock manages 21 customers (highest among reps). Analyze her sales patterns and **standardize best practices into training modules** to improve efficiency and customer relationship management across the sales team.

---

## Technologies Used

**PostgreSQL** (SQL queries, CTEs, aggregations, SQL Window Functions)

---

## Database Schema
- **Artist** (275 records) - Artist information
- **Album** (347 records) - Album catalog
- **Track** (3,503 records) - Individual songs with metadata
- **Customer** (59 records) - Customer profiles and demographics
- **Invoice** (412 records) - Sales transactions
- **InvoiceLine** (2,240 records) - Detailed purchase items
- **Employee** (8 records) - Sales representatives
- **Genre** (25 records) - Music categories
- **MediaType** (5 records) - Audio formats
- **Playlist** (18 records) - Curated collections
- **PlaylistTrack** (8,715 records) - Playlist compositions

---

## Usage
1. Load Chinook database into PostgreSQL
2. Execute analytical queries across relational tables
3. Apply insights to optimize sales and inventory strategies

---

## Outcome
Comprehensive business intelligence for digital music retail optimization through customer segmentation, geographic targeting, and inventory management improvements.

