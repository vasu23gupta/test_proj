const express = require('express');
const fs = require('fs');
const router = express.Router();
const Vendor = require('../models/Vendor');
const Image = require('../models/Image');
const multer = require('multer');

const storage = multer.diskStorage({
    filename: function (req, file, cb) {
        cb(null, file.originalname);
    }
});

const fileFilter = (req, file, cb)=>{
    if(file.mimetype === 'image/jpeg' || file.mimetype=== 'image/png'){
        cb(null, true);
    } else {
        cb(null, false);
    }
};

const upload = multer({
    storage: storage, 
    limits: {
        fileSize: 15 * 1024 * 1024
    }
});

//get an image by id
router.get('/:imageId', async (req, res) => {
    //https://stackoverflow.com/questions/28440369/rendering-a-base64-png-with-express
    try {
        var imageBase64 = await Image.findById(req.params.imageId);
        imageBase64=imageBase64['img']['data'];
        const image = Buffer.from(imageBase64, 'base64');
        res.writeHead(200, {
            'Content-Type': 'image',
            'Content-Length': image.length
        });
        res.end(image);
    } catch (err) {
        res.json({message: err});
    }
});

//upload an image
router.post('/', upload.single('vendorImg'), async function (req, res) {
    var f = req.file;
    var image = new Image();
    image.img.data = fs.readFileSync(f.path);
    image.img.contentType = f.mimetype;
    image.vendorId=req.body.vendorId;
    console.log(req.body.vendorId);

    try {
        const savedImage = await image.save();
        var updatedVendor = await Vendor.updateOne({ _id: req.body.vendorId }, {
            $push: {
                images: savedImage._id
            },
        });

        res.json(savedImage);
    } catch (err) {
        res.json({ message: err });
    }
});

// router.post('/:vendorImg',async function (req, res) {
//     // var f = req.file;
//     var image = new Image();
//     image.img.data = req.params.vendorImg;
//     image.img.contentType = "";

    
//     try {
//         const savedImage = await image.save();
//         res.json(savedImage);
//     } catch (err) {
//         res.json({ message: err });
//     }
// });

module.exports = router;