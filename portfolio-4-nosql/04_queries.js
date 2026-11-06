// Portfolio 4: MongoDB queries for Shoptackles
db = db.getSiblingDB("shoptackles");

print("4a: products with at least 6 GB of RAM");
printjson(db.products.find({ "attributes.ramGb": { $gte: 6 } }, { name: 1, "attributes.ramGb": 1 }).toArray());

print("4b: products available in size M");
printjson(db.products.find({ "attributes.sizes": "M" }, { name: 1, "attributes.sizes": 1 }).toArray());

print("4c: vendor offers for the earbuds");
printjson(db.products.findOne({ name: "Wireless Earbuds" }, { name: 1, offers: 1 }));

print("4d: order history for customer 1");
printjson(db.orders.find({ "customer.customerId": 1 }, { orderDate: 1, status: 1, totalAmount: 1, items: 1 }).toArray());

print("4e: revenue per vendor");
printjson(db.orders.aggregate([
  { $unwind: "$items" },
  { $group: {
      _id: "$items.vendorName",
      unitsSold: { $sum: "$items.quantity" },
      revenue: { $sum: { $multiply: ["$items.quantity", "$items.unitPrice"] } }
  } },
  { $sort: { revenue: -1 } }
]).toArray());