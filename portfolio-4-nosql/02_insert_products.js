db.products.insertMany([
  {
    _id: 1,
    name: "Samsung Galaxy A15 Phone",
    description: "Android smartphone",
    category: "Electronics",
    isActive: true,
    attributes: { brand: "Samsung", ramGb: 6, storageGb: 128, color: "Black" },
    offers: [
      { vendorId: 1, vendorName: "TechHub Nigeria", price: 185000, stock: 23 }
    ]
  },
  {
    _id: 2,
    name: "Wireless Earbuds",
    description: "Bluetooth earbuds",
    category: "Electronics",
    isActive: true,
    attributes: { type: "Bluetooth", batteryHours: 24, color: "White" },
    offers: [
      { vendorId: 1, vendorName: "TechHub Nigeria", price: 15000, stock: 60 },
      { vendorId: 3, vendorName: "HomeNest Stores", price: 16500, stock: 0 }
    ]
  },
  {
    _id: 3,
    name: "Ankara Dress",
    description: "Handmade Ankara fabric dress",
    category: "Fashion",
    isActive: true,
    attributes: { sizes: ["S", "M", "L"], colors: ["Blue", "Green"], fabric: "Ankara cotton" },
    offers: [
      { vendorId: 2, vendorName: "StyleHouse Lagos", price: 22000, stock: 40 }
    ]
  },
  {
    _id: 4,
    name: "Non-stick Frying Pan",
    description: "28cm frying pan",
    category: "Home & Kitchen",
    isActive: true,
    attributes: { diameterCm: 28, material: "Aluminium", dishwasherSafe: true },
    offers: [
      { vendorId: 3, vendorName: "HomeNest Stores", price: 12500, stock: 30 }
    ]
  }
])