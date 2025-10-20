const orderRouter = require('express').Router();
const orderController = require('../controllers/orderController');

orderRouter.post('/order',orderController.saveOrder);
orderRouter.get('/getOrderData',orderController.getOrder);

module.exports = orderRouter;