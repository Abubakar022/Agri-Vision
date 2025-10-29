// D:\FYP\agri_vision\app-backend\controllers\userController.js

const userServices = require('../services/userServices');

exports.createUser = async (req, res, next) => {
  try {
    const { uId, phone, role } = req.body;

    // 'result' will now be an object: { user: {...}, isNew: true/false }
    const result = await userServices.createUser(uId, phone, role);

    // Check the 'isNew' flag from the result object
    const message = result.isNew 
      ? 'User created successfully' 
      : 'User logged in successfully';

    res.json({
      status: 'success',
      success: message,
      user: result.user, // Send back just the user document
    });
  } catch (err) {
    next(err); // pass to global error handler
  }
};