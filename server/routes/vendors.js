const express = require('express');
const router = express.Router();
const Vendor = require('../models/Vendor');

// get all vendors
router.get('/', async (req,res)=>{
    try{
        const vendors = await Vendor.find();
        res.json(vendors);
    }catch(err){
        res.json({message:err});
    }
});

//get one vendor by id
router.get('/:vendorId', async (req,res)=>{
    try{
        const vendor = await Vendor.findById(req.params.vendorId);
        res.json(vendor);
    }catch(err){
        res.json(vendor);
    }
})

//add a vendor
router.post('/', async (req,res)=>{
    const vendor = new Vendor({
        name: req.body.name,
        lat: req.body.lat,
        lng: req.body.lng,
        tags: req.body.tags
    })

    try{
    const savedVendor = await vendor.save();
        res.json(savedVendor);
    } catch(err){
        res.json({message: err});
    }
});

//delete vendor
router.delete('/:vendorId', async (req,res)=>{
    try{
    const removedVendor = await Vendor.deleteOne({_id: req.params.vendorId});
    res.json(removedVendor);
    }catch(err){
        res.json({message: err});
    }
});

//update vendor
router.patch('/:vendorId', async (req,res)=>{
    try{
        const updatedVendor = await Vendor.updateOne({_id: req.params.vendorId},{$set:{
            //set params
            
        }});
        res.json(updatedVendor);
        }catch(err){
            res.json({message: err});
        }
});

module.exports = router;