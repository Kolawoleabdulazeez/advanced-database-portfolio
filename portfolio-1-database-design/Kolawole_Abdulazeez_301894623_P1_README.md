# Portfolio 1: Database Design and Modelling (Shoptackles)

## Overview
This project focuses on designing and building a relational database for Shoptackles, a multi-vendor e-commerce platform where customers can purchase products from different vendors in one order.

I designed the database using PostgreSQL, created the tables and relationships, inserted sample data and tested the database constraints to ensure data accuracy and consistency.

## What the Project Covers
- Designing the database structure and relationships.
- Creating 12 tables using PostgreSQL.
- Defining primary keys, foreign keys and database constraints.
- Inserting sample data into the database.
- Testing the database to ensure invalid records and operations are rejected.
- Applying database normalisation principles.

## Design Summary
The database consists of 12 tables covering customers, vendors, products, orders, payments, deliveries and reviews.

The design also supports important business operations such as:
- Allowing multiple vendors to sell the same product at different prices.
- Supporting orders containing products from different vendors.
- Managing multiple payment attempts for an order.
- Tracking separate deliveries for different vendors.
- Maintaining accurate purchase records even when product prices change.

## Testing and Results
I carried out tests to verify that the database was working as expected.

- Confirmed that all 12 tables were created successfully.
- Verified that sample records were inserted correctly.
- Tested six invalid operations, including duplicate payments, negative order quantities and invalid customer references.
- All six tests were rejected by PostgreSQL as expected.

Screenshots of the database structure, sample records and test results are available in the `evidence/` folder.

## Key Learnings
- Learned how to translate business requirements into a relational database design.
- Understood how tables and relationships work together.
- Learned how database constraints help maintain data integrity.
- Gained practical experience with database normalisation and its application.
- Understood the importance of considering real business operations when designing a database.

## How to Reproduce
Using PostgreSQL 17, run the scripts in the following order:

1. `01_create_database.sql`
2. `02_schema.sql`
3. `03_sample_data.sql`
4. `04_constraint_tests.sql`

Follow the instructions in the scripts and run the constraint tests individually to verify the results.