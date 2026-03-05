// modules/user.js
const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  uId: {
    type: String,
    required: true,
    unique: true // This creates the index automatically!
  },
  email: {
    type: String,
    required: true,
    unique: true, // This creates the index automatically!
    lowercase: true,
    trim: true
  },
  phone: {
    type: String
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  verified: {
    type: Boolean,
    default: true
  },
  fullName: {
    type: String,
    default: ''
  },
  address: {
    district: String,
    tehsil: String,
    city: String,
    fullAddress: String
  },
  isActive: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// DELETE THESE LINES - They are causing the duplicate error
// userSchema.index({ email: 1 }); 
// userSchema.index({ uId: 1 });

const userModel = mongoose.model("users", userSchema);
module.exports = userModel;