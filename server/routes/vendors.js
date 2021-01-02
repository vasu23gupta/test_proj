const express = require('express');
//var fs = require('fs');
const router = express.Router();
const Vendor = require('../models/Vendor');
//const Image = require('../models/Image');
//const multer  = require('multer')
//const upload = multer({dest: './uploads/'});
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
        tags: req.body.tags,
        images: req.body.images
    });

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

// router.post('/photo', upload.single('vendorImg'), async function(req,res){
//     var f = req.file;
//     //console.log(f);
//     var image = new Image();
//     image.img.data = fs.readFileSync(f.path)
//     image.img.contentType = f.mimetype;

//     try {
//         const savedImage = await image.save();
//         res.json(savedImage);
//     } catch (err) {
//         res.json({ message: err });
//     }
//    });

module.exports = router;