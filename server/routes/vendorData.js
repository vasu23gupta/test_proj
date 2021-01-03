const express = require('express');
//var fs = require('fs');
const router = express.Router();
const VendorData = require('../models/VendorData');

// get all vendor data
router.get('/', async (req, res) => {
    try {
        const vendorData = await VendorData.find();
        res.json(vendorData);
    } catch (err) {
        res.json({ message: err });
    }
});

//get one vendor data by id
router.get('/:vendorDataId', async (req, res) => {
    try {
        const vendorData = await VendorData.findById(req.params.vendorDataId);
        res.json(vendorData);
    } catch (err) {
        res.json({message: err});
    }
});

//add vendor data
router.post('/', async (req, res) => {
    const vendorData = new VendorData({
        images: req.body.images,
        description: req.body.description
    });

    try {
        const savedVendorData = await vendorData.save();
        res.json(savedVendorData);
    } catch (err) {
        res.json({ message: err });
    }
});

//delete vendor data
router.delete('/:vendorDataId', async (req, res) => {
    try {
        const removedVendorData = await Vendor.deleteOne({ _id: req.params.vendorDataId });
        res.json(removedVendorData);
    } catch (err) {
        res.json({ message: err });
    }
});

//update vendor data
router.patch('/:vendorDataId', async (req, res) => {
    try {
        const updatedVendorData = await VendorData.updateOne({ _id: req.params.vendorDataId }, {
            $set: {
                //set params

            }
        });
        res.json(updatedDataVendor);
    } catch (err) {
        res.json({ message: err });
    }
});

module.exports = router;