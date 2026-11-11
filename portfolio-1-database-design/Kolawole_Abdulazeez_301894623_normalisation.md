# Portfolio 1: Database Normalisation (Shoptackles)

## 1NF (First Normal Form)

The database follows 1NF by ensuring that every column stores a single, atomic value. For example, phone numbers are stored individually rather than as a list, while addresses are broken down into separate fields such as street, city, and state.

Repeating groups are also eliminated. Instead of storing multiple products in a single order record, each item is recorded as a separate row in the `order_items` table. This makes it easier to manage, retrieve, and update individual order items.

Every table also has a primary key that uniquely identifies each record.

## 2NF (Second Normal Form)

All tables with single-column primary keys automatically satisfy 2NF, provided they already meet the requirements of 1NF.

For tables that represent relationships between two entities, such as `vendor_products`, `order_items`, and `reviews`, surrogate primary keys are used alongside UNIQUE constraints on the relevant column pairs.

This ensures that duplicate relationships cannot be created while maintaining a clear record identifier.

The non-key attributes in these tables, including `price`, `stock_quantity`, `quantity`, `unit_price`, and `rating`, depend on the complete relationship being represented rather than on just one part of it.

### Why `price` is in `vendor_products` and not in `products`

A price describes a particular vendor selling a particular product, not the product on its own. Two vendors can buy the same item from different suppliers at different costs and therefore charge different prices. If the price were stored in `products`, the table could hold only one price per product, and a vendor could end up being charged or paid at another vendor's price.

Fixing that by adding `vendor_id` to `products` would mean repeating the product name and description for every vendor. The name would then depend on only part of the key, which is a partial dependency and breaks 2NF. Keeping the price in `vendor_products` means the facts about the product live in `products` and the facts about the vendor-product pairing live in `vendor_products`.

## 3NF (Third Normal Form)

The tables are structured to ensure that non-key attributes depend on the primary key, the whole primary key, and nothing but the primary key.

The following explains how this is achieved across the database:

| Table | Why it satisfies 3NF |
|---|---|
| `customers` | Customer name, phone number, and email depend entirely on `customer_id`. |
| `addresses` | Street, city, and state describe a particular address. See the note below. |
| `vendors` | Vendor business information depends entirely on `vendor_id`. |
| `categories` | Category name and description depend entirely on `category_id`. |
| `products` | Product name and description depend on `product_id`. Price is excluded because it can vary across vendors. |
| `vendor_products` | Price and stock quantity depend on the specific vendor-product combination. |
| `orders` | The table stores `customer_id` as a reference rather than duplicating customer details such as name and email. |
| `order_items` | Quantity and unit price describe a specific item within an order. |
| `payments` | Payment method, amount, and status describe an individual payment attempt. |
| `deliveries` | Delivery status and relevant dates describe a vendor's shipment for an order. |
| `delivery_agents` | Agent information depends entirely on `agent_id`. |
| `reviews` | Rating and comment describe a customer's review of a particular product. |

**Note on addresses:**

City does not functionally determine state in this context, because the same city or town name can occur in more than one Nigerian state. Since knowing the city does not tell us the state, there is no transitive dependency, and `addresses` remains in 3NF.

I also chose not to introduce separate lookup tables for cities and states. Keeping both as columns makes each address explicit and avoids extra complexity that would add little value at the current scale of the application.

## Deliberate Denormalisation

Although the database is designed around normalisation principles, two fields are intentionally retained to support business requirements and improve data retrieval.

**1. `order_items.unit_price`**

The unit price is captured at the time an order is placed rather than being retrieved dynamically from the current product price.

This is important because product prices may change over time. Keeping the original purchase price ensures that historical orders remain accurate even when vendors update their prices.

**2. `orders.total_amount`**

The total amount is derived from the individual items in an order. However, it is stored directly in the `orders` table as a snapshot to support faster reporting and retrieval without having to calculate the total from order items every time.

To maintain data consistency, updates to the order items and the corresponding total amount will be handled within a database transaction, as covered in Portfolio 3.