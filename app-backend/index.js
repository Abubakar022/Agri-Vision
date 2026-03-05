const app = require('./app');
const connectDB = require('./config/db');
const userModel = require('./modules/user');
const orderModel = require('./modules/Order');
const NotificationService = require('./services/notificationService'); // ADD THIS

const PORT = process.env.PORT || 5000;

// 1. Database se Connect Karein
connectDB();

// 🔥 ADD THIS - Initialize Firebase
try {
  NotificationService.initializeFirebase();
  console.log('✅ Firebase Notification Service initialized');
} catch (error) {
  console.error('❌ Failed to initialize Firebase:', error);
}

// 2. Server ko Start Karein
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));