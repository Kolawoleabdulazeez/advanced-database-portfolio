# Shoptackles: Case Study (MIT 8103 Portfolio)

## 1. Organisation

Shoptackles is a multi-vendor e-commerce platform where independent vendors list products and customers browse, compare and buy them in one place. Products are organised into categories such as Electronics, Fashion and Home & Kitchen.

This is a product I have worked on, and for the purpose of this academic portfolio, I have used Shoptackles as the basis for designing and documenting a relational database. The data used throughout this portfolio is simulated and does not represent actual customer, vendor or transaction records from the live application.

## 2. Nature of the System

The database is designed to support the core activities involved in running an online retail platform. These include managing customer accounts and addresses, vendor product listings, vendor-specific prices and stock quantities, order processing, payments, deliveries and customer reviews.

An important part of the system is the relationship between vendors and products. Different vendors can offer the same product at different prices and with different stock quantities. Customers can also place a single order containing products from multiple vendors. Each vendor fulfils their portion of the order through a separate delivery.

For this portfolio, the focus is strictly on the database and its ability to support these business operations.

The following features are outside the scope of this portfolio: shopping cart, wishlist, coupons, promotions, delivery charges and newsletters.

## 3. The Problem

Shoptackles addresses some of the challenges customers encounter when shopping online across different sellers.

- **Fragmented shopping:** Customers often have to visit several stores to find products across different categories.
- **Product and price comparison:** Comparing available products, prices and sellers can be difficult when information is spread across different stores.
- **Order management:** Customers need a reliable way to keep records of their purchases and access their order history.

Shoptackles provides a centralised marketplace where customers can discover products and make purchases from different vendors.

## 4. Users of the Database

The database supports different categories of users, depending on their responsibilities within the platform.

**Customers**

Customers interact with the platform to explore available products, place orders and manage their purchases. Their information, delivery addresses and order records are maintained in the database. Customers can also submit ratings and reviews for products. In the live application, reviews are intended for products the customer has purchased.

**Vendors**

Vendors are responsible for the products they offer on the platform. Their records include business information, product listings, prices and available stock quantities. Since different vendors can sell the same product, the database maintains their individual product listings separately.

**Administrators**

Administrators oversee the general operations of the platform. They need access to relevant customer, vendor, product, order and transaction records to manage the platform and monitor its activities. Administrators are database users with broad access to records, managed through database roles rather than a table.

**Delivery Agents**

Delivery agents are responsible for handling assigned shipments. One delivery agent can be assigned to multiple deliveries, while each delivery maintains its own shipment information, status and relevant dates.

## 5. Major Data Stored

| Table | Responsibility |
|---|---|
| `customers` | Stores customer information. |
| `addresses` | Maintains customer delivery addresses. |
| `vendors` | Stores vendor business information. |
| `categories` | Organises products into categories. |
| `products` | Maintains general product information. |
| `vendor_products` | Connects vendors to products and holds vendor-specific prices and stock quantities. |
| `orders` | Records customer orders. |
| `order_items` | Stores the individual products associated with an order. |
| `payments` | Records payment attempts and their statuses. |
| `deliveries` | Manages shipments, with a separate delivery for each vendor involved in an order. |
| `delivery_agents` | Stores delivery agent information. |
| `reviews` | Maintains customer ratings and feedback for products. |

## 6. Key Operations

The database is expected to support the following operations:

1. Register customers and maintain their account information.
2. Store and retrieve customer delivery addresses.
3. Register vendors and maintain their business information.
4. Create and manage product categories.
5. Add products to the catalogue and retrieve product information.
6. Associate products with vendors while maintaining vendor-specific prices and stock quantities.
7. Retrieve available products across different vendors for comparison.
8. Create customer orders containing multiple items, including products from different vendors.
9. Record individual order items, quantities and the unit prices at the time of purchase.
10. Update and retrieve order statuses.
11. Record payment attempts and track their respective statuses, including failed attempts and retries.
12. Create and manage separate deliveries for the different vendors involved in a single order.
13. Assign delivery agents to shipments, allowing one agent to handle multiple deliveries.
14. Update and retrieve delivery information.
15. Allow customers to submit ratings and reviews (restricted to purchased products at the application level).
16. Prevent customers from submitting more than one review for the same product.
17. Retrieve customer order histories, vendor sales records and relevant transaction information.

## 7. Technical Considerations

- **Data integrity:** Primary keys, foreign keys, unique constraints and check constraints are used to maintain consistency across related records and prevent invalid data from being stored.

- **Inventory management:** Stock is tracked per vendor and product because multiple vendors can offer the same product, each with different prices and available quantities.

- **Order management:** Each order maintains its own records, including the unit price of products at the time of purchase. This ensures that subsequent changes to catalogue prices do not affect historical orders.

- **Multi-vendor order fulfilment:** A single customer order can contain products from multiple vendors. Each vendor fulfils their portion of the order through a separate delivery. The database maintains the relationship between the original order, its items, the respective vendors and their deliveries.

- **Payment management:** Payment attempts are tracked separately from orders so that failed transactions, successful payments and retries can be recorded independently. The database also ensures that an order can have at most one successful payment.

- **Delivery management:** One delivery agent can handle multiple deliveries. Each delivery is associated with a particular order and vendor to ensure that shipments can be managed independently.

- **Review validation:** The database prevents a customer from submitting more than one review for the same product through a unique constraint on the customer and product. Restricting reviews to products the customer has purchased is an application-level rule.

- **Transaction management:** Operations involving orders, order items and stock updates must either succeed or fail together. This helps prevent situations where an order is recorded without the corresponding inventory update, or vice versa. This will be addressed further in Portfolio 3.