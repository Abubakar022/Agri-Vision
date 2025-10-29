// D:\FYP\agri_vision\app-backend\controllers\orderController.js

const SaveOrder = require('../services/orderServices');

exports.saveOrder = async (req, res, next) => {
  try {
    const { userId, Username, phone, district, tehsil, city, address, acres, price, cancellationReason } = req.body;
    
    const user = await SaveOrder.saveOrder(userId, Username, phone, district, tehsil, city, address, acres, price, cancellationReason);
    
    res.json({ status: 'success', success: "Order Saved successfully" });

  } catch (err) {
    // --- FIX: Proper error handling ---
    console.error("Error saving order:", err); 
    res.status(500).json({ status: 'error', message: 'Failed to save order' });
  }
};


exports.getOrder = async (req, res, next) => {
  try {
    // --- FIX 1: Use req.query, NOT req.body ---
    const { userId } = req.query; 

    // Add a check in case userId is missing
    if (!userId) {
      return res.status(400).json({ status: 'error', message: 'User ID is required' });
    }

    // This line will now work
    const user = await SaveOrder.getOrderData(userId);
    
    res.json({ status: 'success', success: user });

  } catch (err) {
    // --- FIX 2: Proper error handling ---
    console.error("Error getting order:", err); // Logs the real error in your backend terminal
    res.status(500).json({ status: 'error', message: 'Failed to get orders' });
  }
};