// Portfolio 4: insert the order documents (safe to re-run)
db = db.getSiblingDB("shoptackles");
db.orders.deleteMany({});
db.orders.insertMany([
  {
    _id: 1,
    orderDate: ISODate("2026-10-20T09:15:00Z"),
    status: "paid",
    totalAmount: 215000,
    customer: { customerId: 1, name: "Amina Yusuf", email: "amina.yusuf@example.com" },
    shippingAddress: { street: "12 Allen Avenue", city: "Ikeja", state: "Lagos" },
    items: [
      { productId: 1, productName: "Samsung Galaxy A15 Phone", vendorId: 1, vendorName: "TechHub Nigeria", quantity: 1, unitPrice: 185000 },
      { productId: 2, productName: "Wireless Earbuds", vendorId: 1, vendorName: "TechHub Nigeria", quantity: 2, unitPrice: 15000 }
    ],
    payments: [
      { method: "card", amount: 215000, status: "failed" },
      { method: "bank_transfer", amount: 215000, status: "successful", paidAt: ISODate("2026-10-20T09:20:00Z") }
    ],
    deliveries: [
      { vendorId: 1, agent: "Musa Ibrahim", status: "shipped", shippedAt: ISODate("2026-10-21T08:00:00Z") }
    ]
  },
  {
    _id: 2,
    orderDate: ISODate("2026-10-22T14:40:00Z"),
    status: "pending",
    totalAmount: 34500,
    customer: { customerId: 2, name: "Chinedu Okafor", email: "chinedu.okafor@example.com" },
    shippingAddress: { street: "5 Garki Road", city: "Garki", state: "Abuja" },
    items: [
      { productId: 3, productName: "Ankara Dress", vendorId: 2, vendorName: "StyleHouse Lagos", quantity: 1, unitPrice: 22000 },
      { productId: 4, productName: "Non-stick Frying Pan", vendorId: 3, vendorName: "HomeNest Stores", quantity: 1, unitPrice: 12500 }
    ],
    payments: [
      { method: "ussd", amount: 34500, status: "pending" }
    ],
    deliveries: [
      { vendorId: 2, agent: null, status: "processing" },
      { vendorId: 3, agent: null, status: "processing" }
    ]
  },
  {
    _id: 3,
    orderDate: ISODate("2026-10-25T11:05:00Z"),
    status: "paid",
    totalAmount: 16500,
    customer: { customerId: 3, name: "Tolu Adeyemi", email: "tolu.adeyemi@example.com" },
    shippingAddress: { street: "22 Ring Road", city: "Ibadan", state: "Oyo" },
    items: [
      { productId: 2, productName: "Wireless Earbuds", vendorId: 3, vendorName: "HomeNest Stores", quantity: 1, unitPrice: 16500 }
    ],
    payments: [
      { method: "card", amount: 16500, status: "successful", paidAt: ISODate("2026-10-25T11:10:00Z") }
    ],
    deliveries: []
  }
]);