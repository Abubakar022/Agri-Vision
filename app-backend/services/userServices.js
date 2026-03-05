// services/userServices.js - FIXED VERSION
const userModel = require('../modules/user');
const otpModel = require('../modules/otp');
const { generateOTP, sendEmailOTP } = require('./emailService');

class userServices {
  // Request OTP via email (یہ وہی رہے گا)
  static async requestOTP(email) {
    try {
      const otp = generateOTP();
      const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
      
      await otpModel.deleteOne({ email });
      await otpModel.create({ email, otp, expiresAt });
      
      const emailSent = await sendEmailOTP(email, otp);
      
      if (!emailSent) {
        throw new Error('Failed to send OTP email');
      }
      
      return { 
        success: true, 
        message: 'OTP sent successfully',
        email 
      };
      
    } catch (err) {
      throw new Error('Error sending OTP: ' + err.message);
    }
  }

  // ✅ FIXED: Verify OTP - موجودہ user کی uId نہیں بدلے گا
  static async verifyAndCreateUser(email, otp) {
    try {
      // Find OTP
      const otpRecord = await otpModel.findOne({ 
        email, 
        otp,
        expiresAt: { $gt: new Date() }
      });
      
      if (!otpRecord) {
        throw new Error('Invalid or expired OTP');
      }
      
      // Find existing user by email
      const existingUser = await userModel.findOne({ email });
      
      let user;
      let isNew = false;
      
      if (existingUser) {
        // ✅ EXISTING USER: uId نہیں بدلے گا
        // بس verified اور updatedAt update کریں
        existingUser.verified = true;
        existingUser.updatedAt = new Date();
        await existingUser.save();
        user = existingUser;
      } else {
        // ✅ NEW USER: نئی uId بنے گی
        const uId = 'USER' + Date.now();
        const newUser = new userModel({
          uId,
          email,
          role: 'user',
          verified: true,
          isActive: true
        });
        
        await newUser.save();
        user = newUser;
        isNew = true;
      }
      
      // Delete used OTP
      await otpModel.deleteOne({ _id: otpRecord._id });
      
      const userObj = user.toObject();
      delete userObj.__v;
      
      return { 
        user: userObj, 
        isNew 
      };
      
    } catch (err) {
      throw new Error('Error verifying OTP: ' + err.message);
    }
  }

  // ✅ نئی method: Get user by email (uId کی بجائے)
  static async getUserByEmail(email) {
    try {
      const user = await userModel.findOne({ email });
      
      if (!user) {
        throw new Error('User not found');
      }
      
      return user.toObject();
      
    } catch (err) {
      throw new Error('Error fetching user: ' + err.message);
    }
  }

  // باقی methods وہی رہیں گی
  static async getStats() {
    try {
      const total = await userModel.countDocuments();
      const active = await userModel.countDocuments({ isActive: true });
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const newToday = await userModel.countDocuments({ 
        createdAt: { $gte: today } 
      });

      return { 
        total, 
        active, 
        newToday,
        inactive: total - active 
      };
    } catch (err) {
      throw new Error('Error getting stats: ' + err.message);
    }
  }

  static async getUserById(uId) {
    try {
      const user = await userModel.findOne({ uId });
      
      if (!user) {
        throw new Error('User not found');
      }
      
      return user.toObject();
      
    } catch (err) {
      throw new Error('Error fetching user: ' + err.message);
    }
  }

  static async updateUserProfile(uId, updateData) {
    try {
      const allowedFields = ['fullName', 'address'];
      const updateObj = {};
      
      allowedFields.forEach(field => {
        if (updateData[field] !== undefined) {
          updateObj[field] = updateData[field];
        }
      });
      
      updateObj.updatedAt = new Date();
      
      const user = await userModel.findOneAndUpdate(
        { uId },
        updateObj,
        { new: true, runValidators: true }
      );
      
      if (!user) {
        throw new Error('User not found');
      }
      
      return user.toObject();
      
    } catch (err) {
      throw new Error('Error updating profile: ' + err.message);
    }
  }
}

module.exports = userServices;