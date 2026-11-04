# Portfolio 2: Query Processing and Optimisation (Shoptackles)

## Overview
This project explores how PostgreSQL handles database queries and how adding the right indexes can improve query performance.

I tested five common business queries using sample Shoptackles data, measured their execution times, and compared the results before and after adding indexes.

## What the Project Covers
- Generating realistic sample data for the database.
- Running five queries based on common business operations.
- Measuring query performance before indexing.
- Adding six indexes to improve data retrieval.
- Comparing execution times and reviewing the improvements.

## Test Data
The database contains approximately:
- 50,000 customers
- 200,000 orders
- 400,000 order items
- 120,000 payments
- 160,000 deliveries
- 20,000 vendor offers

## Queries Tested
1. Retrieving a customer's order history.
2. Calculating a vendor's sales over 90 days.
3. Comparing prices of a product across vendors.
4. Finding the ten best-selling products in the last 30 days.
5. Tracking vendor shipments awaiting delivery.

## Results

| Query | Before | After | Improvement |
|---|---:|---:|---:|
| Q1 | 139.581 ms | 0.356 ms | 390× |
| Q2 | 124.407 ms | 76.630 ms | 1.6× |
| Q3 | 5.755 ms | 0.670 ms | 8.6× |
| Q4 | 264.888 ms | 175.785 ms | 1.5× |
| Q5 | 115.397 ms | 3.391 ms | 34× |

The results show that adding appropriate indexes significantly improved the performance of most queries, particularly customer order history and shipment tracking.

## Key Learnings
- Learned how to analyse PostgreSQL query performance.
- Understood how indexes improve data retrieval.
- Learned that not every index improves every query.
- Understood the importance of balancing query speed with database storage and maintenance costs.

## How to Reproduce
Run the SQL scripts in the following order:

1. `01_generate_data.sql`
2. `02_queries.sql`
3. `03_indexes.sql`

Use the provided execution plans and screenshots to compare the results before and after indexing.