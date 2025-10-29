const userModel = require('../modules/user');

class userServices {
  static async createUser(uId, phone, role) {
    try {
      // 1. Try to find the user by their phone number
      const existingUser = await userModel.findOne({ phone: phone });

      // 2. If user is found (login)
      if (existingUser) {
        // Optional: Update the uId in case it changed (e.g., user re-verified)
        existingUser.uId = uId;
        await existingUser.save();
        
        // Return the existing user and a flag indicating they are not new
        return { user: existingUser, isNew: false };
      }

      // 3. If user is NOT found (signup)
      const newUser = new userModel({
        uId,
        phone,
        role,
      });

      // Save the new user
      await newUser.save();

      // Return the new user and a flag indicating they are new
      return { user: newUser, isNew: true };

    } catch (err) {
      // Throw any other errors (e.g., database validation)
      throw new Error('Error finding or creating user: ' + err.message);
    }
  }
}
module.exports = userServices;