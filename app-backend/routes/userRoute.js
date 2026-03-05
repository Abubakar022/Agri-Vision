// D:\FYP\agri_vision\app-backend\routes\userRouter.js
const userRouter = require('express').Router();
const userController = require('../controllers/userController');

// Email OTP Routes
userRouter.post('/request-otp', userController.requestOTP);
userRouter.post('/verify-otp', userController.verifyOTP);

// User Profile Routes
userRouter.put('/profile/:uId', userController.updateProfile);
userRouter.get('/profile/:uId', userController.getUser);

// Backward compatibility routes
userRouter.post('/create', userController.createUser);

// Admin routes
userRouter.get('/stats', userController.getUserStats);

module.exports = userRouter;