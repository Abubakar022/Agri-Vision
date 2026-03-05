const admin = require('firebase-admin');
const FCMToken = require('../modules/FCMToken');
const OrderServices = require('./orderServices');

let initialized = false;

class NotificationService {
  
  static initializeFirebase() {
    if (!initialized) {
      try {
        const serviceAccount = require('../config/firebase-service-account.json');
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
        initialized = true;
        console.log('🔥 [FIREBASE] Admin initialized successfully');
      } catch (error) {
        console.error('❌ [FIREBASE] Failed to initialize:', error);
      }
    }
  }

  static async saveToken(userId, fcmToken, deviceType = 'android', role = 'user') {
    try {
      console.log(`💾 [DB] Saving token for ${role}: ${userId}`);
      const existing = await FCMToken.findOne({ fcmToken });
      
      if (existing) {
        existing.userId = userId;
        existing.deviceType = deviceType;
        existing.role = role;
        await existing.save();
        console.log(`✅ [DB] Updated existing token for ${role}`);
      } else {
        await FCMToken.create({ userId, fcmToken, deviceType, role });
        console.log(`✅ [DB] Created new token for ${role}`);
      }
      return { success: true };
    } catch (error) {
      console.error('❌ [DB] Error saving token:', error);
      return { success: false, error: error.message };
    }
  }

  static async getAdminTokens() {
    try {
      const tokens = await FCMToken.find({ role: 'admin' }).distinct('fcmToken');
      console.log(`🔍 [QUERY] Found ${tokens.length} admin tokens in database.`);
      
      if (tokens.length === 0) {
        // Log all roles currently in DB to see why admin is missing
        const stats = await FCMToken.aggregate([{ $group: { _id: "$role", count: { $sum: 1 } } }]);
        console.log('📊 [DB STATS] Current roles in DB:', stats);
      }
      return tokens;
    } catch (error) {
      console.error('❌ [QUERY] Error getting admin tokens:', error);
      return [];
    }
  }

  static async sendToAdmin(notification, data = {}) {
    try {
      if (!initialized) this.initializeFirebase();

      console.log('📨 [SEND] Starting Admin Notification process...');
      const tokens = await this.getAdminTokens();
      
      if (tokens.length === 0) {
        console.error('❌ [SEND] Aborted: No admin tokens found in DB.');
        return { success: false };
      }

      // We will loop through tokens to get individual error details
      const results = [];
      for (const token of tokens) {
        const message = {
          token: token,
          notification: { title: notification.title, body: notification.body },
          data: { ...data, type: data.type || 'admin_notification' },
          android: {
            priority: 'high',
            notification: { channelId: 'admin_channel', icon: '@mipmap/ic_launcher' }
          }
        };

        try {
          const response = await admin.messaging().send(message);
          console.log(`✅ [FCM SUCCESS] Sent to token: ${token.substring(0, 15)}... | ID: ${response}`);
          results.push({ success: true });
        } catch (error) {
          console.error(`❌ [FCM ERROR] Failed for token ${token.substring(0, 15)}...`);
          console.error(`👉 Error Code: ${error.code}`);
          console.error(`👉 Error Message: ${error.message}`);
          
          if (error.code === 'messaging/registration-token-not-registered') {
            await FCMToken.deleteOne({ fcmToken: token });
            console.log('🗑️ [DB] Deleted expired/invalid token.');
          }
          results.push({ success: false, error: error.code });
        }
      }

      const successCount = results.filter(r => r.success).length;
      return { success: successCount > 0, successCount };

    } catch (error) {
      console.error('❌ [CRITICAL] Unexpected error in sendToAdmin:', error);
      return { success: false, error: error.message };
    }
  }

  // --- Send to User with same debug logic ---
  static async sendToUser(userId, notification, data = {}) {
    try {
      if (!initialized) this.initializeFirebase();
      
      const tokens = await FCMToken.find({ userId, role: 'user' }).distinct('fcmToken');
      console.log(`🔍 [QUERY] Found ${tokens.length} tokens for User: ${userId}`);

      if (tokens.length === 0) return { success: false };

      for (const token of tokens) {
        const message = {
          token: token,
          notification: { title: notification.title, body: notification.body },
          data: { ...data, type: data.type || 'order_status' },
          android: {
            priority: 'high',
            notification: { channelId: 'order_channel' }
          }
        };

        try {
          await admin.messaging().send(message);
          console.log(`✅ [FCM SUCCESS] Sent to User ${userId}`);
        } catch (error) {
          console.error(`❌ [FCM ERROR] User ${userId} failed: ${error.code}`);
        }
      }
      return { success: true };
    } catch (error) {
      console.error('❌ [CRITICAL] sendToUser error:', error);
      return { success: false };
    }
  }

  static async sendOrderCreatedNotification(order) {
    console.log('🚀 [EVENT] New Order Created. Triggering notifications...');
    const decryptedOrder = OrderServices.decryptOrder(order);
    
    // User Notif
    await this.sendToUser(order.userId, {
      title: '🆕 آرڈر موصول ہوگیا',
      body: `آپ کا آرڈر #${order._id.toString().slice(-6)} موصول ہوگیا ہے۔`
    });

    // Admin Notif
    return await this.sendToAdmin({
      title: '🆕 نیا آرڈر موصول ہوا',
      body: `${decryptedOrder.Username} نے نیا آرڈر کیا ہے۔`
    }, {
      type: 'new_order',
      orderId: order._id.toString()
    });
  }

  static getStatusText(status) {
    const map = { 1: 'منتظر', 2: 'مکمل', 3: 'منسوخ', 4: 'شیڈول' };
    return map[status] || 'نامعلوم';
  }

  static async sendOrderStatusNotification(order, oldStatus, newStatus) {
    const statusText = this.getStatusText(newStatus);
    return await this.sendToUser(order.userId, {
      title: 'آرڈر کی حیثیت تبدیل ہوگئی',
      body: `آپ کا آرڈر اب ${statusText} ہے۔`
    }, { orderId: order._id.toString() });
  }
}

module.exports = NotificationService;