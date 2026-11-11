//  MongoDB setup for Shoptackles
// Run from this folder in a normal terminal or paste the lines into an open mongosh session

// Select the shoptackles database. MongoDB creates it when data is first stored.
db = db.getSiblingDB("shoptackles");

// Create the two collections only if they do not already exist
if (!db.getCollectionNames().includes("products")) {
  db.createCollection("products");
}
if (!db.getCollectionNames().includes("orders")) {
  db.createCollection("orders");
}

// Confirm
printjson(db.getCollectionNames());