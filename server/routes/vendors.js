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
        const vendor = await Vendor.findById(req.params.vendorId, { totalStars: 0, totalReviews: 0, reports: 0, totalReports: 0 });
        res.json(vendor);
    } catch (err) {
        res.json({ message: err });
    }
});

//get one vendor by id with optional parameters
router.get('/:vendorId/:name/:tags/:location/:description/:images/:reviews/:rating', async (req, res) => {
    //    if (req.params.vendorId=="null") {
    try {
        //console.log(req.params.name=='true'?1:0);
        const vendor = await Vendor.findById({ _id: req.params.vendorId }, {
            _id: 0,
            __v: 0,
            name: req.params.name == 'true' ? 1 : 0,
            location: req.params.location == 'true' ? 1 : 0,
            tags: req.params.tags == 'true' ? 1 : 0,
            images: req.params.images == 'true' ? 1 : 0,
            description: req.params.description == 'true' ? 1 : 0,
            reviews: req.params.reviews == 'true' ? 1 : 0,
            rating: req.params.rating == 'true' ? 1 : 0
        });
        //console.log(vendor);
        res.json(vendor);
    } catch (err) {
        res.json({ message: err });
    }
    //    }
    // else{
    //     try {
    //         const vendor = await Vendor.findById(req.params.vendorId);
    //         res.json(vendor);
    //     } catch (err) {
    //         res.json({ message: err });
    //     }
    // }
});

//get all within bounds
router.get('/:neLat/:neLng/:swLat/:swLng', async (req, res) => {
    var neLat = req.params.neLat;
    var neLng = req.params.neLng;
    var swLat = req.params.swLat;
    var swLng = req.params.swLng;
    Vendor.find({
        location: {
            $geoWithin: {
                $geometry: {
                    type: 'Polygon',
                    coordinates: [[
                        [neLng, neLat],
                        [neLng, swLat],
                        [swLng, swLat],
                        [swLng, neLat],
                        [neLng, neLat]
                    ]]
                }
            }
        }
    }, { location: true }).exec(function (err, docs) {
        if (err) {
            res.json({ message: err });
        }
        else {
            res.json(docs);
        }
    })

});

//search
router.get('/search/:query', async (req, res) => {

    let searchText = req.params.query;
    searchText = searchText.trim();
    //let searchRegex= searchText;
    var searchTexts = searchText.split(" ");
    var searchTextList = [];
    for (i = 0; i < searchTexts.length; i++) {
        searchTextList.push({
            name: {
                $regex: searchTexts[i]
            }
        })
        searchTextList.push({
            tags: {
                $regex: searchTexts[i]
            }
        })
    }
    var fullTextSearchOptions = {
        "$text": {
            "$search": searchText
        }
    };

    var regexSearchOptions = {
        $or: searchTextList
    };
    Vendor.find(regexSearchOptions, { name: 1, tags: 1 }, function (err, docs) {

        if (err) {
            res.json({ message: err });
        } else if (docs) {
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
        location: { coordinates: [req.body.lng, req.body.lat] },
        tags: req.body.tags,
        images: req.body.images,
        description: req.body.description,
        totalReviews: 0,
        totalStars: 0,
        rating: 0,
        totalReports: 0
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

//add review
router.patch('/review/:vendorId', async (req, res) => {

    try {
        var response = await Vendor.updateOne({ _id: req.params.vendorId }, {
            $push: {
                reviews: req.body.reviewId
            },
            $inc: { totalReviews: 1, totalStars: req.body.stars },
        });

        var vendor = await Vendor.findById(req.params.vendorId, { totalReviews: 1, totalStars: 1, _id: 0 });
        const totalReviews = vendor.totalReviews;
        const totalStars = vendor.totalStars;
        var rating = totalStars / totalReviews;
        rating = Math.round((rating + Number.EPSILON) * 100) / 100

        var updateResult = await Vendor.updateOne({ _id: req.params.vendorId }, {
            $set: { rating: rating }
        });

        res.json(updateResult);
    }
    catch (err) {
        res.json({ message: err });
    }
});

//add report
router.patch('/report/:vendorId', async (req, res) => {

    try {
        var response = await Vendor.updateOne({ _id: req.params.vendorId }, {
            $push: {
                reports: req.body.reportId
            },
            $inc: { totalReports: 1 },
        });

        // if((await Vendor.findById(req.params.vendorId,{totalReports:1, _id:0})).totalReports>=10){
        //     //delete maybe
        // }

        res.json(response);
    }
    catch (err) {
        res.json({ message: err });
    }
});

//edit
router.patch('/edit/:vendorId', async (req, res) => {

    try {
        await Vendor.updateOne({ _id: req.params.vendorId }, {
            $set: {
                name: req.body.name,
                location: { coordinates: [req.body.lng, req.body.lat] },
                tags: req.body.tags,
                images: req.body.images,
                description: req.body.description,
            }
        });

        const updatedVendor = await Vendor.findById(req.params.vendorId,{ totalStars: 0, totalReviews: 0, reports: 0, totalReports: 0 });

        res.json(updatedVendor);
    }
    catch (err) {
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