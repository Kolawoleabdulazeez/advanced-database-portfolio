# Portfolio 3: Transactions and Concurrency (Shoptackles)

## Overview
This project explores how PostgreSQL handles multiple database operations while keeping data accurate and consistent. I tested transactions, rollbacks, and what happens when two users try to update the same data at the same time.

## What the Project Covers
- Creating and committing database transactions.
- Testing how failed operations are rolled back.
- Demonstrating how simultaneous transactions can cause incorrect stock updates.
- Using row locking to prevent stock overselling.
- Comparing PostgreSQL isolation levels.

## Results
The tests showed that:
- Successful transactions saved all changes as expected.
- Failed transactions were rolled back without leaving incomplete records.
- Two simultaneous users were able to oversell available stock.
- Row locking prevented the overselling problem.
- `READ COMMITTED` and `REPEATABLE READ` produced different results when data changed during a transaction.
Concurrent payments Tesing: Tab A inserted a successful payment for order 3 without committing. Tab B's attempt to insert a second successful payment for the same order waited. After Tab A committed, Tab B failed with a unique violation (23505) from the partial unique index, and only one successful payment remained. 

## Key Learnings
- Understood how database transactions protect data consistency.
- Learned how concurrent operations can cause unexpected results.
- Understood how row locking prevents conflicting updates.
- Learned how transaction isolation levels affect what users see when accessing data simultaneously.

## Challenges and What I Learned
One interesting part of this project was seeing two sessions successfully sell the same last unit of stock without PostgreSQL raising an error. It helped me understand how concurrency issues can happen even when individual queries execute successfully. I also learned how row locking makes the second session wait until the first transaction is completed, preventing the problem.