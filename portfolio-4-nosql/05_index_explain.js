// Portfolio 4: effect of an index in MongoDB (test collection with 20,000 generated products)
db = db.getSiblingDB("shoptackles");

// Generate the test data (separate from the real products collection)
db.products_test.drop();
const docs = [];
for (let i = 1; i <= 20000; i++) {
  docs.push({
    _id: i,
    name: "Product " + i,
    category: ["Electronics", "Fashion", "Home & Kitchen"][i % 3],
    attributes: { color: ["Black", "Blue", "Red", "White"][i % 4] },
    offers: [{ vendorId: 1 + (i % 200), price: 1000 + (i % 200000), stock: i % 500 }]
  });
}
db.products_test.insertMany(docs);

function measure(label, filter) {
  const e = db.products_test.find(filter).explain("executionStats");
  print(label);
  print(JSON.stringify(e.queryPlanner.winningPlan));
  printjson({
    docsExamined: e.executionStats.totalDocsExamined,
    returned: e.executionStats.nReturned,
    ms: e.executionStats.executionTimeMillis
  });
}

measure("BEFORE index on name", { name: "Product 15000" });
db.products_test.createIndex({ name: 1 });
measure("AFTER index on name", { name: "Product 15000" });
