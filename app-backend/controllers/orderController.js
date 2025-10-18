const SaveOrder= require('../services/orderServices');
exports.saveOrder = async (req, res,next) => {
try{
    const {userId, Username, phone, district, tehsil, city, address, acres, price ,cancellationReason } = req.body;
    const user = await SaveOrder.saveOrder(userId, Username, phone, district, tehsil, city, address, acres, price ,cancellationReason);
    res.json({status: 'success', success:"Order Saved successfully"});

} catch(err){
    throw err;
}
}