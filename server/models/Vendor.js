const mongoose = require('mongoose');




const VendorSchema = mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    lat: {
        type: String,
        required: true
    },
    lng: {
        type: String,
        required: true
    },
    tags: {
        type: String,
        required: true
    }
})

module.exports = mongoose.model('Vendors', VendorSchema);