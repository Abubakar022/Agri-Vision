const userRouter = require('express').Router();
const userController = require('../controllers/userController');

userRouter.post('/create', userController.createUser);

module.exports = userRouter;