## MIT 8103 Advanced Database Systems: Individual Practical Database Portfolio
## Name: Kolawole Abdulazeez 
## Student ID: 301894623
## Academic session: 2026/2027
GitHub repository: https://github.com/Kolawoleabdulazeez/advanced-database-portfolio.git 


1. Case Study 
Shoptackles is a multi-vendor e-commerce platform where independent vendors list products and customers can browse, compare and purchase products from several vendors in a single order. It is a product I have worked on, but all data used in this portfolio is simulated. The same case study is used across all five portfolios.

•	Users: Customers, vendors, administrators and delivery agents.

•	Major data: Customers and addresses, vendors, categories, products, vendor offers (price and stock), orders and order items, payments, deliveries, delivery agents and reviews.

•	Key operations: Product listing, multi-vendor ordering, stock updates, payment attempts, vendor-specific deliveries, product reviews and sales reporting.


The full case study is documented in `portfolio-1-database-design/case-study.md`. The same case study is used across all five portfolios.

## Repository Structure

```text
advanced-database-portfolio/
├── portfolio-1-database-design/           design, schema, constraints, normalisation
├── portfolio-2-query-optimisation/        queries, execution plans, indexes
├── portfolio-3-transactions-concurrency/  commit, rollback, locking, isolation
├── portfolio-4-nosql/                     MongoDB document model
├── portfolio-5-distributed-cloud/         replica set, failover, design discussion
├── setup-evidence/                        PostgreSQL and MongoDB installation proof
└── README.md                              this file
```

Each portfolio folder contains its own README explaining the work completed, how it was tested and what was learned. Screenshots and other supporting evidence are also included in the relevant `evidence/` folders.

## Tools and Technologies

- PostgreSQL 17 and pgAdmin
- MongoDB 9.0 and mongosh 2.14
- dbdiagram.io for ER modelling
- Visual Studio Code
- Git on Windows

## The Five Portfolios

| Portfolio | Contents | Headline result |
| --- | --- | --- |
| **1. Database Design and Modelling** | ER diagram, 12-table PostgreSQL schema, keys and constraints, sample data, six constraint tests and 3NF normalisation | All six invalid operations were rejected by the database. |
| **2. Query Processing and Optimisation** | 50,003 customers, 200,003 orders, 400,005 order items, five queries, execution plans and six indexes | Q1 improved from 139.6 ms to 0.36 ms, while Q5 improved from 115.4 ms to 3.4 ms. Q2 and Q4 showed smaller improvements, which are explained in the analysis. |
| **3. Transactions and Concurrency** | Commit and rollback, lost update, row locking, isolation levels and concurrent payment testing | Two sessions demonstrated how a lost update could oversell stock. `SELECT ... FOR UPDATE` prevented the issue. |
| **4. NoSQL and Advanced Data Models** | MongoDB product and order collections, five queries and an index test | An order is stored as a single document instead of requiring data from multiple relational tables. An index reduced documents examined from 20,000 to 1. |
| **5. Distributed and Cloud Database Exercise** | Three-node MongoDB replica set, failover, write concern and design discussion of sharding and cloud deployment | A new primary was elected after the original primary was stopped. A `w: 3` write timed out when one node was unavailable. |

## How to Reproduce

### PostgreSQL (Portfolios 1–3)

Run the scripts in the following order:

1. Run `portfolio-1-database-design/01_create_database.sql`, then connect to `ecommerce_db`.
2. Run `02_schema.sql`, followed by `03_sample_data.sql` once. Execute the statements in `04_constraint_tests.sql` one at a time.
3. Run `portfolio-2-query-optimisation/01_generate_data.sql`. Execute the queries in `02_queries.sql` using `EXPLAIN (ANALYZE, BUFFERS)`, then run `03_indexes.sql`.
4. For Portfolio 3, use two pgAdmin Query Tool tabs to simulate separate database sessions. Follow the step-by-step comments in each script.

### MongoDB (Portfolios 4–5)

Run the JavaScript scripts in `portfolio-4-nosql/` using `mongosh`.

For Portfolio 5, follow the replica set setup instructions in `portfolio-5-distributed-cloud/01_replica_set_setup.md`.

Some demonstrations modify data. The relevant scripts include instructions for resetting the data before running them again.

## Evidence

Screenshots of the implementation and test results are available in the `evidence/` folder within each portfolio. Query execution plans are saved as text files in `portfolio-2-query-optimisation/plans/`.

The Git commit history also shows how the project developed progressively throughout the semester.

## Individual Technical Reflection

One of the key decisions I made in designing Shoptackles was separating products from vendor offers. This allowed different vendors to sell the same product at different prices and maintain their own stock records. During the transaction exercises, I also learned how easily concurrent operations can affect stock accuracy. In particular, testing two sessions attempting to purchase the same available stock helped me understand why database locking is important and how SELECT ... FOR UPDATE prevents both transactions from processing the same stock simultaneously.
The query optimisation exercise also changed how I approach database performance. I initially expected indexes to improve every query significantly, but the execution plans showed that the results depend on the query and the amount of data being accessed. 


## Limitations

The three-node MongoDB replica set runs on one laptop. It demonstrates replication, failover and write concern behaviour, but does not demonstrate recovery from an actual hardware or data centre failure.

Sharding, PostgreSQL replication and cloud deployment were discussed as future design options in `portfolio-5-distributed-cloud/03_design_discussion.md`, but were not implemented.

## Individual Work and AI Use Declaration

This is individual work. I used **Claude (Anthropic)** to explain database concepts, review design decisions, assist with drafting SQL and JavaScript scripts, and organise the documentation.

I executed the scripts myself, captured the evidence from my own databases, compared the results with the expected behaviour and reviewed the documentation to ensure I could explain the implementation and results.

## References

- PostgreSQL Global Development Group. *PostgreSQL 17 Documentation*. https://www.postgresql.org/docs/17/
- MongoDB Inc. *MongoDB Manual*. https://www.mongodb.com/docs/manual/
- dbdiagram.io. *Database Diagram Tool*. https://dbdiagram.io/