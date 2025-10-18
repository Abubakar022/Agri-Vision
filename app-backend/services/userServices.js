const userModel = require('../modules/user'); 

class userServices {
static async createUser(uId, phone ,role) {
try{
 const createUser = new userModel({
       uId,
       phone,
       role,
    });
    return await createUser.save();
} catch(err){
    throw new Error('Error creating user: ' + err.message);
}
   
}
}
module.exports = userServices;