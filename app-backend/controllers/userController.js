const userServices = require('../services/userServices');
exports.createUser = async (req, res,next) => {
try{
    const { uId, phone ,role } = req.body;
    const user = await userServices.createUser(uId, phone ,role);
    res.json({status: 'success', success:"User created successfully"});

} catch(err){
    throw err;
}
}