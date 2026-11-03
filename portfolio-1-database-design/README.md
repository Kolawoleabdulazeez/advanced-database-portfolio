# Portfolio 1: Database Design and Modelling (Shoptackles)

## Case Study

Shoptackles is a multi-vendor e-commerce platform where independent vendors can list their products, while customers can browse, compare and purchase products from different vendors in one place.

A customer can place a single order containing products from multiple vendors. However, each vendor is responsible for fulfilling their portion of the order through a separate delivery.

I have used Shoptackles as the basis for this database design and modelling exercise. All the data used in this portfolio is simulated and does not represent actual customer, vendor or transaction records.

The full description of the organisation, its users, the data it stores and the operations it supports can be found in [case-study.md](case-study.md).

## What Is in This Folder?

| File | Purpose |
|---|---|
| `case-study.md` | Explains the organisation, its users, the data stored and the key operations the database supports. |
| `er-diagram.png` / `er-diagram.dbml` | Contains the Entity Relationship Diagram and its DBML source, created using dbdiagram.io. |
| `01_create_database.sql` | Creates the `ecommerce_db` database. |
| `02_schema.sql` | Creates the 12 tables, including their keys, constraints and indexes. |
| `03_sample_data.sql` | Inserts a small set of simulated records into the database. |
| `04_constraint_tests.sql` | Contains six test statements used to verify that the database rejects invalid operations. |
| `normalisation.md` | Explains how the database satisfies 1NF, 2NF and 3NF, including the deliberate denormalisation decisions. |
| `evidence/` | Contains screenshots showing the sample data counts and constraint test results. |

## Design Summary

The database consists of 12 tables:

`customers`, `addresses`, `vendors`, `categories`, `products`, `vendor_products`, `delivery_agents`, `orders`, `order_items`, `payments`, `deliveries` and `reviews`.

Three of these tables act as junction tables, resolving many-to-many relationships between entities.

| Junction table | Connects | Information stored |
|---|---|---|
| `vendor_products` | Vendors and products | Vendor-specific price and stock quantity. |
| `order_items` | Orders and vendor products | Quantity purchased and unit price at the time of purchase. |
| `reviews` | Customers and products | Customer rating and review comment. |

These relationships allow the database to represent how the platform operates without unnecessarily duplicating information.

## Key Design Decisions

During the design process, I had to consider how different parts of the business should be represented in the database. Some of the important decisions I made include:

- **Price is stored in `vendor_products`, not `products`:** Different vendors can offer the same product at different prices. Keeping the price in `vendor_products` ensures that it is associated with the specific vendor offering the product.

- **`order_items.unit_price` stores the purchase-time price:** I decided to retain the unit price at the time an order is placed. This is important because vendors may change their prices later, and those changes should not affect existing order records.

- **One order can have multiple payment attempts, but only one can be successful:** Rather than allowing only one payment record per order, the database retains failed attempts and subsequent retries. A partial unique index ensures that an order cannot have more than one successful payment.

- **One delivery per vendor per order:** Since a single order can contain products from different vendors, each vendor fulfils their portion separately. A `UNIQUE (order_id, vendor_id)` constraint prevents the same vendor from having multiple delivery records for the same order.

- **`vendors.status` instead of a separate active flag:** I used a single status column with values such as `active`, `suspended` and `closed`. This avoids maintaining separate fields that could contradict each other.

- **Surrogate keys with unique constraints:** The junction tables have their own primary keys, alongside UNIQUE constraints on the relevant column pairs. This provides identifiable records while preventing duplicate relationships.

- **Constraints are enforced at the database level:** CHECK constraints are used to validate quantities, prices, ratings and permitted status values. Foreign key relationships with `ON DELETE RESTRICT` also protect records that have historical information attached to them.

- **Deliberate denormalisation:** Two fields, `order_items.unit_price` and `orders.total_amount`, are intentionally retained. The first preserves the purchase-time price, while the second stores an order total snapshot for easier retrieval and reporting. Their consistency will be handled through transactions in Portfolio 3.

- **Review validation:** The database prevents a customer from submitting multiple reviews for the same product. However, restricting reviews to products the customer has actually purchased is handled at the application level.

## How to Reproduce

The database was designed and tested using PostgreSQL 17. It can be recreated using either pgAdmin or psql.

Follow these steps:

1. Run `01_create_database.sql` while connected to the default `postgres` database.
2. Connect to the newly created `ecommerce_db` database and run `02_schema.sql`.
3. Run `03_sample_data.sql` to populate the tables with the simulated records. The script assumes that the auto-generated IDs start at 1.
4. Run the statements in `04_constraint_tests.sql` individually to verify the database constraints. Each test is expected to fail with the corresponding error.

## How It Was Tested

I carried out two main checks to confirm that the database was created correctly and that its constraints behaved as expected.

**1. Schema Verification**

After running the schema script, I confirmed that all 12 tables were created successfully in the `public` schema.

I also checked the number of records inserted into each table after loading the sample data.

The results are available in `evidence/sample-data-counts.png`.

**2. Constraint Testing**

I created six test statements to check whether the database would reject invalid records and operations.

The expected behaviour and actual results are shown below.

| Test | What it verifies | Result |
|---|---|---|
| 1. Second successful payment for an order | The partial unique index prevents more than one successful payment per order. | Unique violation (23505) |
| 2. Negative order quantity | The CHECK constraint on `quantity` prevents negative values. | Check violation (23514) |
| 3. Duplicate customer email | The UNIQUE constraint on `email` prevents duplicate customer email addresses. | Unique violation (23505) |
| 4. Review rating of 6 | The CHECK constraint on `rating` restricts ratings to the permitted range. | Check violation (23514) |
| 5. Order for customer 999 | The foreign key constraint ensures that an order references an existing customer. | Foreign key violation (23503) |
| 6. Delete a customer who has orders | `ON DELETE RESTRICT` prevents deleting a customer with existing order records. | Foreign key violation (23503) |

All six tests were rejected by PostgreSQL as expected. This confirms that the constraints are being enforced by the database rather than relying entirely on application-level validation.

Screenshots of the individual test results are available in `evidence/constraint-test-errors/`.

## Challenges and What I Learned

One of the things I found interesting during this exercise was that designing a database requires understanding how the business operates before deciding how the tables should be structured.

Some of the challenges I encountered include:

- **Modelling the vendor-product relationship:** I initially considered having one vendor associated with each product. However, I realised that different vendors could sell the same product at different prices and with different stock quantities. This led me to introduce the `vendor_products` junction table.

- **Modelling payment attempts:** I had to consider what would happen when a customer's payment failed and they attempted to pay again. Allowing multiple payment records per order preserves the transaction history, while the partial unique index ensures that only one successful payment can exist for an order.

- **Understanding normalisation and when to retain certain data:** I learned that normalisation does not mean removing every repeated value without considering the business requirements. Keeping `unit_price` and `total_amount` is a deliberate decision, and I can explain the reason for retaining each field.

- **Maintaining consistency across the project:** Another challenge was ensuring that the case study, ER diagram, database schema, sample data and constraint tests all reflected the same design decisions. This required several revisions to make sure the different parts of the portfolio were aligned.

Overall, this exercise helped me understand that database design goes beyond creating tables and defining relationships. It requires thinking through the actual operations of a system and ensuring that the database can support them while maintaining data integrity.

## AI Use Declaration

- **Tool used:** Claude (Anthropic).
- **Purpose:** I used AI to explain database concepts, review some of my design decisions, and assist with drafting the SQL scripts, DBML and documentation structure.
- **Verification:** I executed the SQL scripts myself in PostgreSQL, ran the constraint tests and compared the errors returned with the expected behaviour of the database. I also made and reviewed the design decisions, particularly the vendor-product relationship and the handling of payment attempts. Finally, I reviewed and edited the documentation to ensure that I understood the implementation and could explain the decisions made.