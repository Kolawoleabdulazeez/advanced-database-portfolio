# Portfolio 5: Distributed and Cloud Database Exercise (Shoptackles)

## Overview

This portfolio demonstrates how MongoDB replication, failover and write concern work using a three-node replica set on one laptop. It also discusses how Shoptackles could scale through sharding and cloud deployment.

## What Is in This Folder

| File | Purpose |
| --- | --- |
| `01_replica_set_setup.md` | Commands used to create and verify the replica set |
| `02_failover_and_write_concern.md` | Failover and write concern tests |
| `03_design_discussion.md` | Design proposals for sharding, consistency and cloud deployment |
| `evidence/` | Screenshots showing the test results |

## What Was Built

A MongoDB replica set named `shoprs` with three `mongod` processes running on ports `27018`, `27019` and `27020`. Each process uses a separate data folder.

The Portfolio 4 data, consisting of four products and three orders, was loaded into the primary node.

## Results

| Test | Result |
| --- | --- |
| Replica set | One node became PRIMARY and two became SECONDARY (`evidence/rs-status.png`). |
| Replication | Products and orders written to the primary appeared on a secondary, which reported `secondary: true` (`evidence/replication-secondary.png`). |
| Secondary write restriction | A write sent to a secondary was rejected with `not primary` (`evidence/secondary-write-refused.png`). |
| Failover | After the primary on port `27018` was stopped, port `27019` was elected primary and accepted a new order. The restarted node rejoined as a secondary and caught up (`evidence/failover-*.png`). |
| Write concern | `w: "majority"` was acknowledged with all three nodes running and with one node down. `w: 3` timed out with one node down (code 64), although the write was stored on the primary (`evidence/wc-*.png`). |

## Analysis

**Availability:** With three nodes, a majority requires two. When one node was stopped, the remaining two maintained a majority and elected a new primary within seconds. The stopped node later rejoined and replicated the changes it had missed.

**Consistency:** Write concern determines how many nodes must acknowledge a write. `majority` allows writes to continue when one node is unavailable, while `w: 3` cannot be satisfied when any node is down. The test also showed that a timeout does not necessarily mean a write failed. Applications should verify the outcome before retrying, especially for payments.

**Design decisions:** Orders, payments and stock require strong consistency, so the proposed approach is to write with `majority` and read from the primary. Product catalogue reads can use secondary nodes where slightly outdated data is acceptable. For future growth, sharding `orders` by customer ID could keep customer order-history queries targeted to one shard, although vendor reports may need to query multiple shards. Further details are in `03_design_discussion.md`.

## Limitations

All three nodes ran on one laptop. The exercise demonstrated replication, elections, failover and write concern, but did not test recovery from an actual hardware or data centre failure.

Sharding, PostgreSQL replication and cloud deployment were discussed as future design options but were not implemented.

## Challenges and What I Learned

One challenge was understanding the warnings that appeared when I first started the MongoDB instances. Seeing several warnings before initiating the replica set made it difficult to tell whether something was wrong or whether the setup was simply incomplete.

Another thing that surprised me was that the old primary did not automatically become primary again after restarting. It rejoined as a secondary and caught up with the changes made while it was offline. This helped me understand how MongoDB handles failover and keeps the replica set synchronised.

## AI Use Declaration

- **Tool used:** Claude (Anthropic).
- **Used for:** Understanding replication, failover, write concern and sharding, drafting setup commands, and organising the design discussion and README.
- **How I verified the work:** I executed the commands on my own machine, captured screenshots of the results and compared the observed behaviour with the expected outcomes. I can explain each test and what it demonstrates.