const SaveOrder = require('../services/orderServices');

// ================== ADMIN CONTROLLERS ==================


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
// Get all orders (with optional status filter)
exports.getAllOrders = async (req, res) => {
  try {
    const { status } = req.query;
    const orders = await SaveOrder.getAllOrders(status);
    res.json({ status: 'success', data: orders });
  } catch (err) {
    console.error("Error getting all orders:", err);
    res.status(500).json({ status: 'error', message: 'Failed to get orders' });
  }
};

// Get single order by ID
exports.getOrderById = async (req, res) => {
  try {
    const { id } = req.params;
    const order = await SaveOrder.getOrderById(id);
    if (!order) return res.status(404).json({ status: 'error', message: 'Order not found' });
    res.json({ status: 'success', data: order });
  } catch (err) {
    console.error("Error getting order by ID:", err);
    res.status(500).json({ status: 'error', message: 'Failed to get order' });
  }
};

// Update order status (accept, complete, cancel)
exports.updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, cancellationReason } = req.body;
    const updated = await SaveOrder.updateOrderStatus(id, status, cancellationReason);
    res.json({ status: 'success', data: updated });
  } catch (err) {
    console.error("Error updating order status:", err);
    res.status(500).json({ status: 'error', message: 'Failed to update order status' });
  }
};

// Schedule an order
exports.scheduleOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const { scheduleDate } = req.body;
    const scheduled = await SaveOrder.scheduleOrder(id, scheduleDate);
    res.json({ status: 'success', data: scheduled });
  } catch (err) {
    console.error("Error scheduling order:", err);
    res.status(500).json({ status: 'error', message: 'Failed to schedule order' });
  }
};

// Delete an order
exports.deleteOrder = async (req, res) => {
  try {
    const { id } = req.params;
    await SaveOrder.deleteOrder(id);
    res.json({ status: 'success', message: 'Order deleted successfully' });
  } catch (err) {
    console.error("Error deleting order:", err);
    res.status(500).json({ status: 'error', message: 'Failed to delete order' });
  }
};
// ================== ADMIN FEATURE: Get User's Previous Orders ==================
// ================== ADMIN FEATURE: Get User's Previous Orders ==================
exports.getUserOrderHistory = async (req, res) => {
  try {
    const { id } = req.params; // Order ID

    const currentOrder = await SaveOrder.getOrderById(id);
    if (!currentOrder) {
      return res.status(404).json({ status: 'error', message: 'Order not found' });
    }

    const previousOrders = await SaveOrder.getPreviousOrders(currentOrder.userId, currentOrder._id);

    res.json({
      status: 'success',
      userId: currentOrder.userId,
      totalPreviousOrders: previousOrders.length,
      previousOrders
    });

  } catch (err) {
    console.error("Error getting user order history:", err);
    res.status(500).json({ status: 'error', message: 'Failed to get user order history' });
  }
};

// ================== ADMIN FEATURE: Order Stats ==================
exports.getOrderStats = async (req, res) => {
  try {
    const stats = await SaveOrder.getOrderStats();
    res.json({
      status: "success",
      stats
    });
  } catch (err) {
    console.error("Error getting order stats:", err);
    res.status(500).json({
      status: "error",
      message: "Failed to get order statistics",
    });
  }
};

// ================== ADMIN FEATURE: Total Revenue ==================
exports.getTotalRevenue = async (req, res, next) => {
  try {
    const totalRevenue = await SaveOrder.getTotalRevenue();
    res.json({ status: 'success', totalRevenue });
  } catch (err) {
    console.error("Error getting revenue:", err);
    res.status(500).json({ status: 'error', message: 'Failed to get revenue' });
  }
};


