const orderModel = require("../modules/Order");

class OrderServices {
  static async saveOrder(userId, Username, phone, district, tehsil, city, address, acres, price,cancellationReason) {
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
}
module.exports = OrderServices;