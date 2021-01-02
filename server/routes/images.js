const express = require('express');
const fs = require('fs');
const router = express.Router();
//const Vendor = require('../models/Vendor');
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
    try {
        const image = await Image.findById(req.params.imageId);
        res.json(image);
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

    try {
        const savedImage = await image.save();
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