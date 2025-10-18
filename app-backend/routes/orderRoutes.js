const orderRouter = require('express').Router();
const orderController = require('../controllers/orderController');

orderRouter.post('/order',orderController.saveOrder);

module.exports = orderRouter;