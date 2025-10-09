// index.js (Final CommonJS Version with Mongoose and DB Fix)

// 1. ضروری ماڈیولز (Modules) کو require کریں
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

// .env فائل سے ماحول کے متغیرات (Environment Variables) لوڈ کریں
dotenv.config();
const app = express();

// 2. اہم متغیرات (Crucial Variables)
const MONGO_URI = process.env.MONGODB_URI; // .env سے کنکشن سٹرنگ
const DB_NAME = process.env.MONGODB_DB;   // .env سے ڈیٹا بیس کا نام (Agri_Vision)
const PORT = process.env.PORT || 3000;

// 3. مڈل ویئر (Middleware)
app.use(cors());
app.use(express.json()); // یہ لائن JSON ریکوئسٹ باڈی کو پڑھنے کے لیے ضروری ہے

// 4. MongoDB کنکشن
mongoose.connect(MONGO_URI, { dbName: DB_NAME }) 
  .then(() => {
    console.log("✅ MongoDB Connected");
    // تصدیق کریں کہ یہ صحیح ڈیٹا بیس کے ساتھ جڑا ہے
    console.log(`Connected to DB: ${mongoose.connection.name}`); 
  })
  .catch((err) => console.error("❌ MongoDB Error:", err.message));

// 5. Mongoose سکیما (Schema Definition)
const userSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  phone: { type: String, required: true, unique: true },
  verified: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

const User = mongoose.model("User", userSchema); // کلیکشن کا نام 'users' ہو گا

// 6. API Route: /api/save-user
app.post("/api/save-user", async (req, res) => {
  try {
    const { fullName, phone, verified } = req.body;
    
    // ویلیڈیشن چیک (Validation Check)
    if (!fullName || !phone) {
      return res.status(400).json({ message: "نام یا فون نمبر درکار ہے" });
    }

    // Upsert logic (Update if phone exists, otherwise Insert a new user)
    const updateResult = await User.updateOne(
      { phone }, // فائنڈ کرائیٹیریا
      { 
        $set: {
          fullName, 
          verified: verified ?? true,
          updatedAt: new Date()
        }
      },
      { upsert: true } // اگر یوزر نہ ملا تو نیا بنا دے گا
    );

    // کامیابی کا رسپانس
    if (updateResult.upsertedCount > 0) {
        res.json({ success: true, message: "نیا یوزر کامیابی سے محفوظ ہو گیا" });
    } else {
        res.json({ success: true, message: "یوزر کامیابی سے اپ ڈیٹ ہو گیا" });
    }
  } catch (error) {
    console.error("API Error:", error);
    // اگر یونیک (Unique) کی خرابی ہو تو یہیں آ سکتی ہے
    res.status(500).json({ message: "سرور میں مسئلہ پیش آیا", error: error.message });
  }
});

// 7. سرور چلائیں (Start Server)
app.listen(PORT, () =>
  console.log(`🚀 Server running on port ${PORT}`)
);