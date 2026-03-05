const admin = require("firebase-admin");
const mongoose = require("mongoose");
const FCMToken = require("./modules/FCMToken"); // Make sure the path is correct
require("dotenv").config();

async function testPush() {
  try {
    const serviceAccount = require("./config/firebase-service-account.json");
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    console.log("Firebase initialized");

    await mongoose.connect(process.env.MONGODB_URI + process.env.MONGODB_DB);
    console.log("MongoDB connected");

    const tokens = await FCMToken.find({ userId: "USER1764860390033" });
    console.log(`Found ${tokens.length} tokens for user`);

    if (tokens.length > 0) {
      const token = tokens[0].fcmToken;
      console.log("Sending to token:", token.substring(0, 20) + "...");

      const message = {
        token: token,
        notification: {
          title: "Test Notification",
          body: "This is a test from the backend script.",
        },
        data: { type: "test" },
        android: {
          priority: "high",
          notification: { channelId: "order_channel" },
        },
      };

      try {
        const response = await admin.messaging().send(message);
        console.log("✅ Success:", response);
      } catch (err) {
        console.error("❌ FCM Error:", err.message, err.code);
      }
    }
  } catch (err) {
    console.error("Error:", err);
  } finally {
    mongoose.disconnect();
  }
}

testPush();
