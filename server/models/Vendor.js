const mongoose = require('mongoose');




const VendorSchema = mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    lat: {
        type: Number,
        required: true
    },
    lng: {
        type: Number,
        required: true
    },
    tags: {
        type: String,
        required: true
    }
})

module.exports = mongoose.model('Vendors', VendorSchema);