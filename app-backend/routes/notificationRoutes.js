const express = require('express');
const router = express.Router();
const NotificationService = require('../services/notificationService');
const FCMToken = require('../modules/FCMToken');

// ✅ SIMPLE TEST ENDPOINT - Add this first!
router.get('/test', (req, res) => {
  console.log('✅ Test endpoint hit!');
  res.json({ 
    status: 'success', 
    message: 'Backend is reachable!',
    timestamp: new Date().toISOString()
  });
});

// ✅ CONNECTION TEST ENDPOINT
router.get('/test-connection', (req, res) => {
  console.log('✅ Connection test endpoint hit!');
  res.json({ 
    status: 'success', 
    message: 'Connection working!',
    serverTime: new Date().toISOString()
  });
});

// Save FCM token
// Save FCM token
router.post('/save-fcm-token', async (req, res) => {
  console.log('📥 Received save-fcm-token request');
  console.log('📥 Body:', req.body);
  
  try {
    // 1. EXTRACT ROLE: We must get 'role' from req.body
    const { userId, fcmToken, role } = req.body; 
    
    if (!userId || !fcmToken) {
      console.log('❌ Missing userId or fcmToken');
      return res.status(400).json({ 
        status: 'error', 
        message: 'userId and fcmToken are required' 
      });
    }

    // 2. FIX DEVICE TYPE: Instead of guessing from headers, check if Flutter sent it
    // If Flutter didn't send it, default to 'android' (better for your Agri Vision testing)
    const deviceType = req.body.deviceType || 'android'; 
    
    console.log(`📱 Saving for Device: ${deviceType} | Role: ${role || 'user'}`);
    
    // 3. PASS THE ROLE: Crucial step to stop admins being saved as users
    const result = await NotificationService.saveToken(
      userId, 
      fcmToken, 
      deviceType, 
      role || 'user' // If no role provided, then it's a user
    );
    
    if (result.success) {
      console.log(`✅ Token saved successfully for ${role || 'user'}:`, userId);
      res.json({ status: 'success', message: 'Token saved successfully' });
    } else {
      console.log('❌ Failed to save token:', result.error);
      res.status(500).json({ status: 'error', message: result.error });
    }
  } catch (error) {
    console.error('❌ Error in save-fcm-token:', error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});
// Remove FCM token (logout)
router.post('/remove-fcm-token', async (req, res) => {
  console.log('📥 Received remove-fcm-token request');
  
  try {
    const { userId, fcmToken } = req.body;
    await NotificationService.removeToken(userId, fcmToken);
    console.log('✅ Token removed for user:', userId);
    res.json({ status: 'success', message: 'Token removed successfully' });
  } catch (error) {
    console.error('❌ Error removing token:', error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// Get user's tokens (for debugging)
router.get('/user-tokens/:userId', async (req, res) => {
  console.log('📥 Received user-tokens request for:', req.params.userId);
  
  try {
    const { userId } = req.params;
    const tokens = await FCMToken.find({ userId });
    console.log(`✅ Found ${tokens.length} tokens for user ${userId}`);
    
    res.json({ 
      status: 'success', 
      count: tokens.length,
      tokens: tokens.map(t => ({ 
        token: t.fcmToken.substring(0, 20) + '...', 
        deviceType: t.deviceType,
        createdAt: t.createdAt 
      }))
    });
  } catch (error) {
    console.error('❌ Error getting tokens:', error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// Test notification endpoint
router.post('/test-notification/:userId', async (req, res) => {
  console.log('📥 Received test-notification request for user:', req.params.userId);
  
  try {
    const { userId } = req.params;
    const { title, body } = req.body;
    
    const result = await NotificationService.sendToUser(
      userId, 
      { 
        title: title || 'ٹیسٹ نوٹیفکیشن', 
        body: body || 'یہ ایک ٹیسٹ پیغام ہے۔' 
      },
      { type: 'test' }
    );
    
    console.log('✅ Test notification result:', result);
    res.json(result);
  } catch (error) {
    console.error('❌ Error sending test notification:', error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

module.exports = router;