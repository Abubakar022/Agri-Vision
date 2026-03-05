const mongoose = require('mongoose');

const fcmTokenSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  fcmToken: {
    type: String,
    required: true,
    unique: true
  },
  deviceType: {
    type: String,
    enum: ['android', 'ios'],
    default: 'android'
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user',
    index: true
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

// Compound indexes for faster queries
fcmTokenSchema.index({ userId: 1, fcmToken: 1 });
fcmTokenSchema.index({ role: 1 }); // For quickly finding all admin tokens
fcmTokenSchema.index({ userId: 1, role: 1 }); // For user-specific queries with role
fcmTokenSchema.index({ role: 1, createdAt: -1 }); // For admin queries sorted by date

// Update timestamp on save
fcmTokenSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Method to check if token is valid
fcmTokenSchema.methods.isExpired = function() {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  return this.updatedAt < thirtyDaysAgo;
};

const FCMToken = mongoose.model('FCMToken', fcmTokenSchema);

module.exports = FCMToken;