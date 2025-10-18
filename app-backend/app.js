const express=require('express');
const body_parser = require('body-parser');
const userRouter = require('./routes/userRoute');
const orderRouter = require('./routes/orderRoutes');
 const app = express();
 app.use(body_parser.json());


 app.use('/',userRouter);

 app.use('/',orderRouter);

  module.exports=app;