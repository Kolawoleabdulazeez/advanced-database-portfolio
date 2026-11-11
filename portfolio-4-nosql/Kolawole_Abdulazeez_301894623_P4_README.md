# Portfolio 4: NoSQL and Advanced Data Models (Shoptackles)

## Overview
This project explores how MongoDB can be used to manage Shoptackles data. I created document-based models for products and orders, tested different queries and compared how indexing affects data retrieval.

## What the Project Covers
- Creating product and order collections in MongoDB.
- Storing flexible product details and related information in documents.
- Running queries to retrieve and analyse business data.
- Comparing embedded documents with relational database structures.
- Testing how indexes improve query performance.

## Results
The project demonstrated that:
- MongoDB can store products with different attributes without requiring the same structure for every product.
- Related order information can be stored together in a single document.
- Queries can retrieve related information without multiple table joins.
- Adding an index reduced the number of documents MongoDB needed to examine from 20,000 to just 1.

## Key Learnings
- Understood the differences between relational and document databases.
- Learned how to structure data using collections and embedded documents.
- Understood how MongoDB indexes improve query performance.
- Learned that flexibility and simplicity come with trade-offs, especially when managing relationships and maintaining data consistency.

## Conclusion
MongoDB offers flexibility when handling products with different attributes and related information. However, PostgreSQL remains a better fit for critical operations such as stock management and payments, where data consistency is essential. Both databases have their strengths depending on the requirements.

## How to Reproduce
With MongoDB running, execute the scripts in the following order:

1. `01_setup.js`
2. `02_insert_products.js`
3. `03_insert_orders.js`
4. `04_queries.js`
5. `05_index_explain.js`