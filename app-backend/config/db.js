// config/db.js

require('dotenv').config(); // Yeh line sab se upar honi chahiye
const mongoose = require('mongoose');

const MONGO_URI = process.env.MONGODB_URI;
const DB_NAME = process.env.MONGODB_DB;

const connectDB = async () => {
  try {
    // Check karein ke URI empty tou nahi hai
    if (!MONGO_URI) {
      throw new Error('MONGODB_URI is not defined in .env file');
    }
    
    await mongoose.connect(MONGO_URI, { dbName: DB_NAME });
    console.log(`✅ MongoDB connected to database: ${DB_NAME}`);
  } catch (err) {
    console.error("❌ MongoDB Connection Error:", err.message);
    // Agar connection fail ho toh server band kar dein
    process.exit(1); 
  }
};

// Yahan se function ko export karein taake index.js usay import kar sakay
module.exports = connectDB;