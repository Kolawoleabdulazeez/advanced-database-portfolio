# MongoDB Replica Set Setup (Shoptackles)

## Overview
This project involves setting up a three-node MongoDB replica set called `shoprs` on a Windows laptop.

Each node runs independently with its own port and data folder. The setup was used to test data replication, read operations and what happens when a database node becomes unavailable.

**Environment:**
- Windows 11
- MongoDB Server 9.0.4
- MongoDB Shell (mongosh) 2.14.1
- Three nodes running on ports `27018`, `27019` and `27020`.

## 1. Create the Data Folders

I created separate folders for each node to store its database files.

```bash
mkdir C:\mongo-rs\node1
mkdir C:\mongo-rs\node2
mkdir C:\mongo-rs\node3
```

## 2. Start the Three MongoDB Servers

I opened three separate Command Prompt windows and ran one command in each to start the servers.

```bash
"C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe" --replSet shoprs --port 27018 --dbpath C:\mongo-rs\node1 --bind_ip localhost

"C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe" --replSet shoprs --port 27019 --dbpath C:\mongo-rs\node2 --bind_ip localhost

"C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe" --replSet shoprs --port 27020 --dbpath C:\mongo-rs\node3 --bind_ip localhost
```

Each server runs independently but belongs to the same replica set.

## 3. Initialise the Replica Set

I connected to the first node using:

```bash
mongosh --port 27018
```

Then I initialised the replica set:

```javascript
rs.initiate({
  _id: "shoprs",
  members: [
    { _id: 0, host: "localhost:27018" },
    { _id: 1, host: "localhost:27019" },
    { _id: 2, host: "localhost:27020" }
  ]
})
```

To confirm that the setup was successful, I checked the status:

```javascript
rs.status().members.map(m => ({
  name: m.name,
  state: m.stateStr
}))
```

The result showed one PRIMARY and two SECONDARY nodes.

Screenshot: `evidence/rs-status.png`

## 4. Load the Shoptackles Data

I loaded the sample products and orders from Portfolio 4 into the primary node.

- `02_insert_products.js` inserted 4 products.
- `03_insert_orders.js` inserted 3 orders.

I confirmed the records using:

```javascript
use shoptackles

db.products.countDocuments()  // 4
db.orders.countDocuments()    // 3
```

Screenshot: `evidence/replication-primary.png`

## 5. Verify Data Replication

I connected to the second node using:

```bash
mongosh --port 27019
```

Then I checked whether the data from the primary was available:

```javascript
use shoptackles

db.products.countDocuments()  // 4

db.orders.find(
  { _id: 2 },
  { customer: 1, totalAmount: 1 }
)

db.hello().secondary  // true
db.hello().primary    // localhost:27018
```

The results confirmed that the secondary node had received the data from the primary.

Screenshot: `evidence/replication-secondary.png`

## 6. Test Writes on a Secondary Node

I attempted to insert a new product while connected to the secondary:

```javascript
db.products.insertOne({
  _id: 99,
  name: "Test product"
})
```

MongoDB rejected the operation with a `not primary` error because secondary nodes do not accept normal writes.

Screenshot: `evidence/secondary-write-refused.png`

## Key Learnings
- Learned how to set up a MongoDB replica set.
- Understood the difference between primary and secondary nodes.
- Learned how data is replicated across multiple nodes.
- Understood why writes are handled by the primary while secondary nodes can serve reads.
- Gained practical experience preparing a replica set for failover testing.

## How to Reproduce
1. Create the three data folders.
2. Start the three MongoDB servers using the commands above.
3. Connect to port `27018` and initialise the replica set.
4. Load the Shoptackles sample data.
5. Connect to a secondary node and verify replication.
6. Attempt a write on the secondary to confirm that it is rejected.

**Note:** All three nodes run on the same laptop. This setup demonstrates MongoDB replication but does not provide protection against failure of the physical machine.