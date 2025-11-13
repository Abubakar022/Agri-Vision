const orderRouter = require('express').Router();
const orderController = require('../controllers/orderController');

orderRouter.post('/order',orderController.saveOrder);
orderRouter.get('/getOrderData',orderController.getOrder);
orderRouter.get('/admin/orders', orderController.getAllOrders);
orderRouter.get('/admin/order/:id', orderController.getOrderById);
orderRouter.put('/admin/order/:id/status', orderController.updateOrderStatus);
orderRouter.put('/admin/order/:id/schedule', orderController.scheduleOrder);
orderRouter.delete('/admin/order/:id', orderController.deleteOrder);
orderRouter.get('/admin/order/:id/previous', orderController.getUserOrderHistory);
orderRouter.get('/admin/orders/stats', orderController.getOrderStats);
orderRouter.get('/totalRevenue', orderController.getTotalRevenue);
module.exports = orderRouter;