const orderModel = require("../modules/Order");
const { encrypt, decrypt } = require("../utils/crypto");
const NotificationService = require('./notificationService');

class OrderServices {

  static async saveOrder(userId, Username, phone, district, tehsil, city, address, acres, price, cancellationReason, scheduleDate) {
    try {
      console.log('📝 Creating new order for user:', userId);
      
      const saveOrder = new orderModel({
        userId,
        Username: encrypt(Username),
        phone: encrypt(phone),
        district: encrypt(district),
        tehsil: encrypt(tehsil),
        city: encrypt(city),
        address: encrypt(address),
        acres,
        price,
        cancellationReason,
        scheduleDate,
      });

      const saved = await saveOrder.save();
      console.log('✅ Order saved to database with ID:', saved._id);
      
      const decrypted = this.decryptOrder(saved);
      
      // 🔔 SEND NOTIFICATION FOR NEW ORDER
      console.log('🔔 Attempting to send order creation notification...');
      try {
        const notifResult = await NotificationService.sendOrderCreatedNotification(saved);
        console.log('📊 Notification send result:', JSON.stringify(notifResult, null, 2));
      } catch (notifError) {
        console.error("❌ Notification error (non-critical):", notifError);
        // Don't throw - notification failure shouldn't break order saving
      }

      return decrypted;
    } catch (err) {
      console.error('❌ Error saving order:', err);
      throw new Error("Error while saving order: " + err.message);
    }
  }

  static decryptOrder(order) {
    if (!order) return order;
    const obj = order.toObject();

    try {
      obj.Username = decrypt(obj.Username);
      obj.phone = decrypt(obj.phone);
      obj.district = decrypt(obj.district);
      obj.tehsil = decrypt(obj.tehsil);
      obj.city = decrypt(obj.city);
      obj.address = decrypt(obj.address);
    } catch (decryptError) {
      console.error('Error decrypting order:', decryptError);
    }

    return obj;
  }

  static async getOrderData(userId) {
    try {
      console.log('📋 Fetching orders for user:', userId);
      const orders = await orderModel.find({ userId }).sort({ createdAt: -1 });
      return orders.map(o => this.decryptOrder(o));
    } catch (err) {
      console.error('❌ Error getting orders:', err);
      throw new Error("Error while getting order: " + err.message);
    }
  }

  static async getAllOrders(status) {
    try {
      console.log('📋 Fetching all orders' + (status ? ` with status: ${status}` : ''));
      const filter = status ? { status } : {};
      const orders = await orderModel.find(filter).sort({ createdAt: -1 });
      return orders.map(o => this.decryptOrder(o));
    } catch (err) {
      console.error('❌ Error getting all orders:', err);
      throw new Error("Error fetching orders: " + err.message);
    }
  }

  static async getOrderById(id) {
    try {
      console.log('🔍 Fetching order by ID:', id);
      const order = await orderModel.findById(id);
      return this.decryptOrder(order);
    } catch (err) {
      console.error('❌ Error getting order by ID:', err);
      throw new Error("Error fetching order: " + err.message);
    }
  }

  static async updateOrderStatus(id, status, cancellationReason = null) {
    try {
      console.log(`📝 Updating order ${id} status to: ${status}`);
      
      // Get current order to know old status
      const currentOrder = await orderModel.findById(id);
      if (!currentOrder) {
        throw new Error("Order not found");
      }
      
      const oldStatus = currentOrder.status;
      
      const update = { status };
      if (status === 3 && cancellationReason) update.cancellationReason = cancellationReason;
      
      const updated = await orderModel.findByIdAndUpdate(id, update, { new: true });
      console.log('✅ Order status updated successfully');
      
      // 🔔 SEND NOTIFICATION FOR STATUS CHANGE
      try {
        console.log('🔔 Sending status change notification...');
        await NotificationService.sendOrderStatusNotification(updated, oldStatus, status);
      } catch (notifError) {
        console.error("❌ Notification error (non-critical):", notifError);
      }
      
      return this.decryptOrder(updated);
    } catch (err) {
      console.error('❌ Error updating order status:', err);
      throw new Error("Error updating order status: " + err.message);
    }
  }

  static async scheduleOrder(id, scheduleDate) {
    try {
      console.log(`📝 Scheduling order ${id} for date:`, scheduleDate);
      
      // Get current order to know old status
      const currentOrder = await orderModel.findById(id);
      if (!currentOrder) {
        throw new Error("Order not found");
      }
      
      const oldStatus = currentOrder.status;
      
      const scheduled = await orderModel.findByIdAndUpdate(
        id, 
        { scheduleDate, status: 4 }, 
        { new: true }
      );
      console.log('✅ Order scheduled successfully');
      
      // 🔔 SEND NOTIFICATION FOR SCHEDULING
      try {
        console.log('🔔 Sending scheduling notification...');
        await NotificationService.sendOrderStatusNotification(scheduled, oldStatus, 4);
      } catch (notifError) {
        console.error("❌ Notification error (non-critical):", notifError);
      }
      
      return this.decryptOrder(scheduled);
    } catch (err) {
      console.error('❌ Error scheduling order:', err);
      throw new Error("Error scheduling order: " + err.message);
    }
  }

  static async deleteOrder(id) {
    try {
      console.log('🗑️ Deleting order:', id);
      return await orderModel.findByIdAndDelete(id);
    } catch (err) {
      console.error('❌ Error deleting order:', err);
      throw new Error("Error deleting order: " + err.message);
    }
  }

  static async getPreviousOrders(userId, currentOrderId) {
    try {
      console.log('📋 Fetching previous orders for user:', userId);
      const orders = await orderModel.find({
        userId,
        _id: { $ne: currentOrderId }
      }).sort({ createdAt: -1 });

      return orders.map(o => this.decryptOrder(o));
    } catch (err) {
      console.error('❌ Error getting previous orders:', err);
      throw new Error("Error fetching previous orders: " + err.message);
    }
  }

  static async getOrderStats() {
    try {
      console.log('📊 Calculating order stats...');
      
      const totalOrders = await orderModel.countDocuments();
      const pendingOrders = await orderModel.countDocuments({ status: 1 });
      const completedOrders = await orderModel.countDocuments({ status: 2 });
      const cancelledOrders = await orderModel.countDocuments({ status: 3 });
      const inProgressOrders = await orderModel.countDocuments({ status: 4 });

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
      console.error('❌ Error getting order stats:', err);
      throw new Error("Error while getting order stats: " + err.message);
    }
  }

  static async getTotalRevenue() {
    try {
      console.log('💰 Calculating total revenue...');
      
      const revenueData = await orderModel.aggregate([
        { $match: { status: 2 } },
        {
          $group: {
            _id: null,
            totalRevenue: { $sum: { $toDouble: "$price" } }
          }
        }
      ]);

      return revenueData.length ? revenueData[0].totalRevenue : 0;
    } catch (err) {
      console.error('❌ Error calculating revenue:', err);
      throw new Error("Error while calculating total revenue: " + err.message);
    }
  }

  static async userCancelOrder(orderId, userId) {
    try {
      console.log(`📝 User ${userId} cancelling order: ${orderId}`);
      
      const order = await orderModel.findOne({ _id: orderId, userId });

      if (!order) {
        throw new Error("Order not found or unauthorized");
      }

      // Sirf pending order cancel ho sakta
      if (order.status !== 1) {
        throw new Error("Only pending orders can be cancelled");
      }

      // Update to cancelled instead of deleting
      order.status = 3;
      order.cancellationReason = "صارف کی جانب سے منسوخ";
      await order.save();
      console.log('✅ Order cancelled successfully');
      
      // 🔔 SEND CANCELLATION NOTIFICATION
      try {
        console.log('🔔 Sending cancellation notification...');
        await NotificationService.sendOrderStatusNotification(order, 1, 3);
      } catch (notifError) {
        console.error("❌ Notification error (non-critical):", notifError);
      }
      
      return true;
    } catch (err) {
      console.error('❌ Error cancelling order:', err);
      throw new Error(err.message);
    }
  }
}

module.exports = OrderServices;