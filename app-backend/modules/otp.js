// modules/otp.js - Clean Version
const mongoose = require("mongoose");
const { Schema } = mongoose;

const otpSchema = new Schema({
  email: {
    type: String,
    required: true,
    lowercase: true,
    trim: true
  },
  otp: {
    type: String,
    required: true,
  },
  expiresAt: {
    type: Date,
    required: true
  },
  attempts: {
    type: Number,
    default: 0,
    max: 3
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  },
});

// TTL index for automatic cleanup (expires after 10 minutes)
otpSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 600 });
// Index for fast email lookups
otpSchema.index({ email: 1 });

const otpModel = mongoose.model("otps", otpSchema);
module.exports = otpModel;