# Chinook Digital Music Store - SQL Analysis  

## Overview 
PostgreSQL analysis of the Chinook Digital Music Store database to extract business insights on customer behavior, sales performance, and inventory optimization across 11 interconnected tables.

---

## Key Insights  
**1. Geographic Revenue Strategy**
USA dominates with 91 invoices but Prague generates highest per-city revenue ($90.24). Scale US operations while implementing Prague's high-value customer acquisition model globally.

**2. Concert & Event Planning**
Rock genre leads with 835 purchases; São Paulo has 40 rock consumers (highest). Prioritize rock concerts in São Paulo, Berlin, and Paris for maximum ROI.

**3. Catalog Optimization Crisis**
43% of tracks (1,518 songs) never sold, creating dead inventory. Remove unpopular tracks, negotiate better licensing deals, or bundle with popular content.

**4. Customer Segmentation Opportunity**
One customer (Helena Holý) spent $49.62 while having premium-price buyers across 27 cities. Develop VIP programs and premium pricing tiers for high-value segments.

**5. Artist Partnership Strategy**
Iron Maiden contributes most content (213 tracks, 21 albums) while 50 artists span multiple genres. Secure exclusive deals with top performers and cross-promote versatile artists.

**6. Sales Team Efficiency**
Jane Peacock manages 21 customers (highest). Analyze her methods and train other sales reps to replicate her customer relationship strategies.

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
