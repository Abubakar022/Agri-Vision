const mongoose = require("mongoose");
const connectDB = require("../config/db");

const { Schema } = mongoose;

const userSchema = new Schema({
  uId: {
    type: String,
    required: true,
    unique: true,
  },
  phone: {
    type: Number,
    required: true,
    unique: true,
  },
  role: {
    type: String,
    enum: ['user', 'admin'], // Only allows these two values
    default: 'user'          // All new users are 'user' by default
  },
  verified: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

const userModel = mongoose.model("users", userSchema);
module.exports = userModel;
