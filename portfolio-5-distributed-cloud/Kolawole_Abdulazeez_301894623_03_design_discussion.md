# Scaling Shoptackles: Replication, Sharding, Consistency and Cloud Deployment

## Overview

This portfolio explores how Shoptackles could scale as the marketplace grows. It covers replication, sharding, consistency and cloud deployment.

The practical work was limited to a three-node MongoDB replica set, documented in `01_replica_set_setup.md` and `02_failover_and_write_concern.md`. Sharding, PostgreSQL replication and cloud deployment are design proposals and were not implemented.

## 1. Why Shoptackles Needs to Scale

As Shoptackles grows, it will handle more customers, orders and traffic. This creates three main challenges:

- **Storage:** More data may exceed the capacity of one server.
- **Performance:** A single server may struggle to handle increasing requests.
- **Availability:** The platform should remain operational when a server fails.

## 2. Replication: What Was Implemented

The MongoDB replica set uses one primary and two secondary nodes. The primary handles writes, while the secondary nodes copy changes through the operation log (oplog).

The implementation demonstrated:

- **Availability:** When the primary was stopped, a secondary was elected as the new primary within seconds, allowing writes to continue.
- **Read scaling:** Secondary nodes can serve read requests, depending on the application's read preference.
- **Data redundancy:** Each node maintains a copy of the dataset.

Replication does not distribute storage or write operations across nodes. Every node holds the full dataset, and the primary handles writes. Sharding would address these limitations.

## 3. Sharding: Data and Shard Key Selection

Sharding distributes a collection across multiple servers. The shard key determines how documents are distributed, so choosing the right key is important.

**Collection selection**

The `orders` collection is the strongest candidate because it is expected to grow faster than the product catalogue. The `products` collection is relatively small and read-heavy, so it can remain on a single replica set.

**Candidate shard keys for `orders`**

| Shard key | Write distribution | Query efficiency | Assessment |
|---|---|---|---|
| `orderDate` | New orders may concentrate on the newest shard | Date queries can be targeted, but customer history may scatter | Poor |
| Sequential `_id` | Can create a hot shard | Single-order lookups are efficient | Poor |
| Hashed `_id` | Distributes writes more evenly | Single-order lookups are efficient, but other queries may scatter | Acceptable |
| `customer.customerId` | Distributes orders across many customers | Customer order history can target one shard | Best fit |
| `items.vendorId` | Not suitable | Not suitable | Invalid because the field is inside an array |

**Recommendation**

Use `customer.customerId` as the shard key for `orders`. This supports the common customer order-history query while distributing data across customers.

The trade-off is that vendor reports, such as revenue per vendor (Portfolio 2, Query 4e), may need to query multiple shards and combine the results. These reports could be handled separately using precomputed summaries or reporting infrastructure to reduce their impact on order processing.

## 4. Scaling the PostgreSQL Database

PostgreSQL remains the system of record for orders, payments and stock.

A practical scaling approach would include:

- **Read replicas:** Use one or more replicas for reporting queries, including Q2 and Q4 from Portfolio 2, to reduce the workload on the primary.
- **Table partitioning:** Partition the `orders` table by date range to make large tables easier to manage and support archiving older records.
- **Sharding:** Consider PostgreSQL sharding only when simpler scaling options are no longer sufficient, as it introduces additional tooling or application-level complexity.

## 5. Consistency: What Must Be Protected?

Distributed databases must manage the trade-off between consistency and availability when failures occur.

The replica set demonstrated that a majority of two nodes could continue accepting writes when one of the three nodes was unavailable. However, a write requiring all three nodes (`w: 3`) timed out.

The following consistency choices are recommended for Shoptackles:

| Data | Requirement | Recommended approach |
|---|---|---|
| Stock, orders and payments | Accuracy is essential to prevent overselling and duplicate payments | Write to the primary using `w: "majority"` and read from the primary |
| Product catalogue and reviews | Slightly outdated data may be acceptable | Allow reads from secondary nodes where appropriate |

A key lesson from the write concern test is that a timeout does not necessarily mean a write failed. The `w: 3` operation was still stored on the primary, even though the acknowledgement timed out.

The application should therefore treat such timeouts as an unknown outcome and verify the operation before retrying. This is particularly important for payments.

## 6. Cloud Deployment

A production deployment could use managed database services to reduce the operational burden of backups, patching and failover.

**Proposed architecture:**

- **MongoDB:** Use a managed replica set, such as MongoDB Atlas, distributed across three availability zones. This helps the database remain available when one zone fails.
- **PostgreSQL:** Use a managed primary instance with a standby in another availability zone for automatic failover, alongside read replicas for reporting.
- **Region:** Select the closest suitable cloud region to Nigerian customers to reduce network latency. The available regions should be checked during deployment.
- **Operations:** Configure automated backups, point-in-time recovery, monitoring, alerts and regular failover tests.
- **Security:** The local MongoDB nodes ran without access control enabled. A production deployment must use authentication, encrypted connections and restricted network access.
- **Cost:** Additional replicas, availability zones and shards increase infrastructure costs. Capacity should be based on actual traffic and growth projections.

## 7. Limitations of the Local Exercise

The three MongoDB nodes ran on a single laptop. The exercise demonstrated replication, primary election, failover and write concern behaviour.

However, it did not demonstrate:

- Recovery from an actual machine or data centre failure.
- Network delays between separate availability zones.
- Performance with production-scale data and traffic.
- MongoDB sharding.
- PostgreSQL replication.
- Cloud deployment.

These remain proposed improvements rather than implemented features.

## Conclusion

The local exercise demonstrated how MongoDB replication and write concern help maintain availability and protect data during node failures. For future growth, Shoptackles could combine MongoDB sharding for its expanding orders collection with PostgreSQL read replicas and partitioning. A managed cloud deployment across multiple availability zones would provide a stronger foundation for reliability, security and scalability.