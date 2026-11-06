# Replica set setup (MongoDB, local 3-node cluster)

This file records the commands used to build a three-node MongoDB replica set called `shoprs` on one Windows laptop. Each node is a separate `mongod` process with its own port and its own data folder. They share one machine, so this simulates a cluster for coursework and cannot survive a failure of the laptop itself.

## Environment
- Windows 11, MongoDB Server 9.0.4, mongosh 2.14.1
- The default MongoDB on port 27017 was left untouched. The replica set uses ports 27018, 27019 and 27020.

## 1. Data folders
Created outside the repository, because they hold database files that must not be committed:
```
mkdir C:\mongo-rs\node1
mkdir C:\mongo-rs\node2
mkdir C:\mongo-rs\node3
```

## 2. Start the three servers
Each command runs in its own Command Prompt window, which stays open while the server runs.
```
"C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe" --replSet shoprs --port 27018 --dbpath C:\mongo-rs\node1 --bind_ip localhost
"C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe" --replSet shoprs --port 27019 --dbpath C:\mongo-rs\node2 --bind_ip localhost
"C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe" --replSet shoprs --port 27020 --dbpath C:\mongo-rs\node3 --bind_ip localhost
```

| Option | Meaning |
|---|---|
| `--replSet shoprs` | The node belongs to a replica set named `shoprs` |
| `--port` | The port this node listens on |
| `--dbpath` | The folder where this node keeps its own copy of the data |
| `--bind_ip localhost` | Only this computer can connect |

Before the set is initiated, the nodes log warnings such as `local.oplog.rs not found` and `No primary exists currently`. This is expected: the oplog is created when the set is initiated.

## 3. Initiate the replica set
Connected with `mongosh --port 27018`:
```js
rs.initiate({
  _id: "shoprs",
  members: [
    { _id: 0, host: "localhost:27018" },
    { _id: 1, host: "localhost:27019" },
    { _id: 2, host: "localhost:27020" }
  ]
})
```

Check the members:
```js
rs.status().members.map(m => ({ name: m.name, state: m.stateStr }))
```
Result: `localhost:27018` is PRIMARY, and `localhost:27019` and `localhost:27020` are SECONDARY (`evidence/rs-status.png`).

## 4. Load the Shoptackles data on the primary
The Portfolio 4 scripts were run against the primary (pasted into a mongosh session connected to port 27018):
- `portfolio-4-nosql/02_insert_products.js` (4 products)
- `portfolio-4-nosql/03_insert_orders.js` (3 orders)

On the primary:
```js
use shoptackles
db.products.countDocuments()   // 4
db.orders.countDocuments()     // 3
```
Evidence: `evidence/replication-primary.png`.

## 5. Check replication from a secondary
Connected with `mongosh --port 27019`:
```js
use shoptackles
db.products.countDocuments()                               // 4 (copied from the primary)
db.orders.find({ _id: 2 }, { customer: 1, totalAmount: 1 })
db.hello().secondary                                       // true
db.hello().primary                                         // 'localhost:27018'
```
Evidence: `evidence/replication-secondary.png`.

## 6. Writes to a secondary are refused
```js
db.products.insertOne({ _id: 99, name: "Test product" })
```
Result: `MongoServerError: not primary`. Only the primary accepts writes, and secondaries are read-only copies (`evidence/secondary-write-refused.png`).

## How replication works here
The primary records every change in its oplog (the `local.oplog.rs` collection). Each secondary copies new oplog entries from the primary and applies them, so all three nodes hold the same data.

## Notes
- The data folders in `C:\mongo-rs` are not part of this repository.
- To stop the cluster, press Ctrl+C in each server window.