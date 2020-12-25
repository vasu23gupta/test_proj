const express = require('express');
const router = express.Router();
const Vendor = require('../models/Vendor');
//const Point = require('../models/Vendor');
// get all vendors
router.get('/', async (req, res) => {
    try {
        const vendors = await Vendor.find();
        res.json(vendors);
    } catch (err) {
        res.json({ message: err });
    }
});

//get one vendor by id
router.get('/:vendorId', async (req, res) => {
    try {
        const vendor = await Vendor.findById(req.params.vendorId);
        res.json(vendor);
    } catch (err) {
        res.json({message: err});
    }
});

//get all within bounds
router.get('/:neLat/:neLng/:swLat/:swLng', async(req,res)=>{
    var neLat = req.params.neLat;
    var neLng = req.params.neLng;
    var swLat = req.params.swLat;
    var swLng = req.params.swLng;
    Vendor.find().where('location').within({
        type: 'Polygon',
        coordinates: [[
            [neLng,neLat],
            [neLng,swLat],
            [swLng,swLat],
            [swLng,neLat],
            [neLng,neLat]
        ]]
    }).exec(function(err,docs){
        if(err) {
            res.json({message: err});
        }
        else{
            res.json(docs);
        }
    })

});

//for testing
router.get('/test', async(req,res)=>{
    res.json(req.body);
});

//search
router.get('/search/:query', async(req,res)=>{

    // try{
    //     const vendors = await Vendor.find({"name": {'$regex': req.params.query, '$options': '$i'}});
    //     res.json(vendors);
    // }catch(err) {
    //     res.json({message: err});
    // }

    const searchString = req.params.query;
    //res.json({message:searchString});
    Vendor.find({$text:{$search: searchString}}).exec(function(err,docs){
        if(err) {
            res.json({message: err});
        }
        else{
            res.json(docs);
        }
    });

})

//add a vendor
router.post('/', async (req, res) => {
    //const point = new Point({ type: req.body.type, coordinates: [req.body.lng, req.body.lat] });
    const vendor = new Vendor({
        name: req.body.name,
        location: {coordinates: [req.body.lng, req.body.lat]},
        tags: req.body.tags
    })

    try {
        //const savedPoint = await point.save();
        const savedVendor = await vendor.save();
        //res.json(savedPoint);
        res.json(savedVendor);
    } catch (err) {
        res.json({ message: err });
    }
});

//delete vendor
router.delete('/:vendorId', async (req, res) => {
    try {
        const removedVendor = await Vendor.deleteOne({ _id: req.params.vendorId });
        res.json(removedVendor);
    } catch (err) {
        res.json({ message: err });
    }
});

//update vendor
router.patch('/:vendorId', async (req, res) => {
    try {
        const updatedVendor = await Vendor.updateOne({ _id: req.params.vendorId }, {
            $set: {
                //set params

            }
        });
        res.json(updatedVendor);
    } catch (err) {
        res.json({ message: err });
    }
});

module.exports = router;