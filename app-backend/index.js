const app = require('./app'); // app.js se import karein
const connectDB = require('./config/db'); // db.js se function import karein
const userModel = require('./modules/user'); // user model import karein
const orderModel = require('./modules/Order'); // order model import karein
// Environment variables (yeh pehle hi load ho chukay hain)
const PORT = process.env.PORT || 5000;

// 1. Database se Connect Karein
connectDB();

// 2. Server ko Start Karein
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));

// --- YAHAN SE AAGE KOI CODE NAHI LIKHNA ---












// const express = require('express');
// const mongoose = require('mongoose');
// const cors = require('cors');

// const orderRoutes = require("./routes/orderRoutes");
// const db =require('./config/db');
// dotenv.config();
// const app = express();

// app.use(cors());
// app.use(express.json());

// app.use("/api/order", orderRoutes);

// const PORT = process.env.PORT || 3000;
// // ✅ MongoDB Connection

// // ✅ Schema
// const userSchema = new mongoose.Schema({
//   phone: { type: String, required: true, unique: true },
//   verified: { type: Boolean, default: true },
//   createdAt: { type: Date, default: Date.now },
//   updatedAt: { type: Date, default: Date.now }
// });

// const User = mongoose.model("User", userSchema);

// // ✅ Route to save/update user
// app.post("/api/save-user", async (req, res) => {
//   try {
//     const { phone, verified } = req.body;

//     if (!phone) return res.status(400).json({ message: "فون نمبر درکار ہے" });

//     const result = await User.updateOne(
//       { phone },
//       { $set: { verified: verified ?? true, updatedAt: new Date() } },
//       { upsert: true }
//     );

//     if (result.upsertedCount > 0) {
//       res.json({ success: true, message: "نیا یوزر کامیابی سے محفوظ ہو گیا" });
//     } else {
//       res.json({ success: true, message: "یوزر پہلے سے موجود ہے، اپ ڈیٹ کر دیا گیا" });
//     }
//   } catch (error) {
//     console.error("Error:", error);
//     res.status(500).json({ message: "سرور میں خرابی", error: error.message });
//   }
// });

// app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
