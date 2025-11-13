const orderModel = require("../modules/Order");

class OrderServices {

  static async saveOrder(userId, Username, phone, district, tehsil, city, address, acres, price,cancellationReason, scheduleDate) {
    try {
      const saveOrder = new orderModel({
        userId,
        Username,
        phone,
        district,
        tehsil,
        city,
        address,
        acres,
        price,
        cancellationReason,
        scheduleDate,
      });
      return await saveOrder.save();
    } catch (err) {
      throw new Error("Error while saving order: " + err.message);
    }
  }
   static async getOrderData(userId) {
    try {
      const orderData = await orderModel.find({
        userId
      });
      return orderData;
    } catch (err) {
      throw new Error("Error while saving order: " + err.message);
    }
  }


  static async getAllOrders(status) {
    const filter = status ? { status } : {};
    return await orderModel.find(filter).sort({ createdAt: -1 });
  }

  static async getOrderById(id) {
    return await orderModel.findById(id);
  }

  static async updateOrderStatus(id, status, cancellationReason = null) {
    const update = { status };
    if (status === 3 && cancellationReason) update.cancellationReason = cancellationReason;
    return await orderModel.findByIdAndUpdate(id, update, { new: true });
  }

  static async scheduleOrder(id, scheduleDate) {
    return await orderModel.findByIdAndUpdate(
      id,
      { scheduleDate, status: 4 }, // 4 = In Progress or Scheduled
      { new: true }
    );
  }

  static async deleteOrder(id) {
    return await orderModel.findByIdAndDelete(id);
  }
  static async getPreviousOrders(userId, currentOrderId) {
  // Return all orders of this user except the current one, sorted by date (newest first)
  return await orderModel.find({
    userId,
    _id: { $ne: currentOrderId }
  }).sort({ createdAt: -1 });
}

static async getOrderStats() {
  try {
    const totalOrders = await orderModel.countDocuments();

    const pendingOrders = await orderModel.countDocuments({ status: 1 });
    const completedOrders = await orderModel.countDocuments({ status: 2 });
    const cancelledOrders = await orderModel.countDocuments({ status: 3 });
    const inProgressOrders = await orderModel.countDocuments({ status: 4 });

    // Optional: Orders pending for more than 24 hours (no response yet)
    const now = new Date();
    const twentyFourHoursAgo = new Date(now - 24 * 60 * 60 * 1000);
    const unrespondedOrders = await orderModel.countDocuments({
      status: 1,
      createdAt: { $lt: twentyFourHoursAgo },
    });

    return {
      totalOrders,
      pendingOrders,
      completedOrders,
      cancelledOrders,
      inProgressOrders,
      unrespondedOrders,
    };
  } catch (err) {
    throw new Error("Error while getting order stats: " + err.message);
  }
}

static async getTotalRevenue() {
    try {
      const revenueData = await orderModel.aggregate([
        { $match: { status: 2 } }, // Only completed orders
        {
          $group: {
            _id: null,
            totalRevenue: { $sum: { $toDouble: "$price" } }
          }
        }
      ]);

      const totalRevenue = revenueData.length > 0 ? revenueData[0].totalRevenue : 0;
      return totalRevenue;
    } catch (err) {
      throw new Error("Error while calculating total revenue: " + err.message);
    }
  }


}

module.exports = OrderServices;
