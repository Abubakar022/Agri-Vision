const mongoose = require("mongoose");
const connectDB = require('../config/db'); 
const orderSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      ref: "User",
      required: true,
    },
    Username: String, 
    phone: String,
    district: String,
    tehsil: String,
    city: String,
    address: String,
    acres: String,
    price: String,
    status: {
      type: Number,
      enum: [1, 2, 3, 4], // 1 = Pending, 2 = Completed, 3 = Cancelled, 4 = In Progress
      default: 1,
    },
    cancellationReason: {
      type: String,
      default: null 
    },
    scheduleDate: {
  type: Date,
  default: null
},

  },
  
  { timestamps: true }
);

const ordermodel = mongoose.model('orders',orderSchema);
module.exports = ordermodel;
