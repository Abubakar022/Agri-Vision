// D:\FYP\agri_vision\app-backend\controllers\userController.js
const userServices = require('../services/userServices');

// Request OTP
exports.requestOTP = async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        status: 'error',
        message: 'Email is required'
      });
    }

    const result = await userServices.requestOTP(email);

    res.json({
      status: 'success',
      success: result.message,
      email: result.email
    });
  } catch (err) {
    next(err);
  }
};

// Verify OTP and create/login user
exports.verifyOTP = async (req, res, next) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        status: 'error',
        message: 'Email and OTP are required'
      });
    }

    const result = await userServices.verifyAndCreateUser(email, otp);

    const message = result.isNew 
      ? 'Account created successfully' 
      : 'Login successful';

    res.json({
      status: 'success',
      success: message,
      user: result.user
    });
  } catch (err) {
    next(err);
  }
};

// Create user with phone (for backward compatibility)
exports.createUser = async (req, res, next) => {
  try {
    const { uId, phone, role } = req.body;

    const result = await userServices.createUserWithPhone(uId, phone, role);

    const message = result.isNew 
      ? 'User created successfully' 
      : 'User logged in successfully';

    res.json({
      status: 'success',
      success: message,
      user: result.user
    });
  } catch (err) {
    next(err);
  }
};

// Update user profile
exports.updateProfile = async (req, res, next) => {
  try {
    const { uId } = req.params;
    const updateData = req.body;

    const user = await userServices.updateUserProfile(uId, updateData);

    res.json({
      status: 'success',
      success: 'Profile updated successfully',
      user
    });
  } catch (err) {
    next(err);
  }
};

// Get user by ID
exports.getUser = async (req, res, next) => {
  try {
    const { uId } = req.params;

    const user = await userServices.getUserById(uId);

    res.json({
      status: 'success',
      user
    });
  } catch (err) {
    next(err);
  }
};

// Get user stats
exports.getUserStats = async (req, res, next) => {
  try {
    const stats = await userServices.getStats();

    res.json({
      status: "success",
      data: stats,
    });
  } catch (err) {
    next(err);
  }
};