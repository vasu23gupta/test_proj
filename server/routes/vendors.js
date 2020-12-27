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
})

//search
router.get('/search/:query', async(req,res)=>{

    let searchText = req.params.query;
    searchText=searchText.trim();
    //let searchRegex= searchText;
    var searchTexts=searchText.split(" ");
    var searchTextList=[];
    for(i=0;i<searchTexts.length;i++)
    {
        searchTextList.push({
            name:{
              $regex: searchTexts[i]
            }
          })
    }
    var fullTextSearchOptions = {
        "$text":{
          "$search": searchText
        }
      };
      
      var regexSearchOptions = {
          $or: searchTextList
      };
      Vendor.find(regexSearchOptions, function(err, docs){

        if(err){
          res.json({message: err});
        }else if(docs){
          res.json(docs);
        }
      
      });
    
    //res.json({message:searchString});
    /* try {
        const vendors=await Vendor.find({$text:{$search: searchString}})
        for (var i=0;i<vendors.length;i++)
        {
            vendors[i]=json(vendors[i]);
        }
        res.json(vendors)
    }catch(err)
    {
        res.json({message: err})
    } */

    // const searchString=req.params.query;
    // Vendor.find({$text:{$search: searchString}}).exec(function(err,docs){
    //     if(err) {
    //         res.json({message: err});
    //     }
    //     else{
    //         res.json(docs);
    //     }
    // });
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