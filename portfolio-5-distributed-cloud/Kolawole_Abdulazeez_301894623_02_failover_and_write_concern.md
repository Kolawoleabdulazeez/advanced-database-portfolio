# Portfolio 5: Failover and Write Concern (MongoDB Replica Set `shoprs`)

## Overview
This project explores how MongoDB maintains availability and data consistency using a three-node replica set.

I tested what happens when the primary node goes offline, how another node takes over, and how different write concern settings affect database operations.

All three nodes were run on one laptop, so the tests demonstrate replica set failover rather than protection against physical hardware failure.

## Part 1: Failover Test

The purpose of this test was to confirm that MongoDB could continue operating when the primary node became unavailable.

### How I Ran the Test

**1. Checked the initial replica set status**

I used the following command to check the state of all three nodes:

```javascript
rs.status().members.map(m => ({
  name: m.name,
  state: m.stateStr,
  health: m.health
}))
```

The result showed that port `27018` was PRIMARY, while `27019` and `27020` were SECONDARY. All three nodes were healthy.

Screenshot: `evidence/failover-before.png`

**2. Stopped the primary node**

From a MongoDB shell connected to port `27018`, I ran:

```javascript
use admin
db.shutdownServer()
```

**3. Checked the replica set again**

After waiting approximately 10 to 15 seconds, I checked the replica set status again.

Port `27019` had automatically been elected as the new PRIMARY.

Screenshot: `evidence/failover-status.png`

**4. Tested a new write**

I connected to the new primary and inserted an order:

```javascript
use shoptackles

db.orders.insertOne({
  _id: 4,
  // remaining order fields
})

db.orders.countDocuments()
```

The operation was successful, and the order count increased to 4.

Screenshot: `evidence/failover-write.png`

**5. Restarted the failed node**

I restarted port `27018` using its original MongoDB startup command.

The node rejoined the replica set as a SECONDARY and automatically caught up with the changes made while it was offline.

Screenshot: `evidence/failover-recovered.png`

### Result
The test confirmed that when one node goes offline, the remaining two nodes can elect a new primary and continue accepting writes. The failed node also recovered automatically when restarted.

## Part 2: Write Concern Test

Write concern determines how many replica set members must acknowledge a database write before MongoDB confirms that it is successful.

I used a separate collection called `wc_test` so the tests would not affect the actual Shoptackles data.

### How I Ran the Test

I performed three tests using different write concern settings.

**Test 1: Majority write concern with all nodes available**

```javascript
db.wc_test.insertOne(
  { test: 1 },
  { writeConcern: { w: "majority", wtimeout: 5000 } }
)
```

All three nodes were running, and the write was successfully acknowledged.

Screenshot: `evidence/wc-majority.png`

**Test 2: Requiring all three nodes**

I stopped port `27020` and ran:

```javascript
db.wc_test.insertOne(
  { test: 2 },
  { writeConcern: { w: 3, wtimeout: 5000 } }
)
```

The operation returned a `WriteConcernTimeout` error after five seconds because all three nodes could not acknowledge the write.

However, the write had already been stored on the primary.

Screenshot: `evidence/wc-timeout.png`

**Test 3: Majority write concern with one node offline**

With port `27020` still offline, I ran:

```javascript
db.wc_test.insertOne(
  { test: 3 },
  { writeConcern: { w: "majority", wtimeout: 5000 } }
)
```

The operation was successfully acknowledged because the remaining two nodes formed a majority.

Screenshot: `evidence/wc-majority-one-down.png`

After restarting port `27020`, I checked the collection and confirmed that all three documents were available.

Screenshot: `evidence/wc-recovered.png`

### Results

| Write Concern | What It Means |
|---|---|
| `w: 1` | Only the primary needs to acknowledge the write. |
| `w: "majority"` | Most of the replica set members must acknowledge the write. |
| `w: 3` | All three nodes must acknowledge the write. |

The tests showed that majority write concern could still work with one node offline, while requiring all three nodes resulted in a timeout.

## Key Learnings
- Understood how MongoDB replica sets improve database availability.
- Learned how automatic failover works when a primary node goes offline.
- Understood how different write concern settings affect database operations.
- Learned that a write timeout does not always mean the data was not saved.
- Understood the importance of balancing data consistency and system availability.

## Application to Shoptackles
For Shoptackles, I would use majority write concern for important operations such as orders and payments to improve write durability.

Product catalogue reads can also be served from secondary nodes where slightly delayed updates are acceptable.

Overall, this exercise helped me understand how database replication supports availability and how write concern helps determine the reliability of database writes.

## How to Reproduce
1. Follow `01_replica_set_setup.md` to set up the three-node replica set.
2. Run the failover test using the commands documented in Part 1.
3. Run the write concern tests in Part 2.
4. Restart any stopped nodes and verify that they rejoin the replica set.

Screenshots of the tests and results are available in the `evidence/` folder.