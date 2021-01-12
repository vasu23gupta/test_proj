const mongoose = require('mongoose');

const VendorDataSchema = mongoose.Schema({
    images: {
        type: [String],
        required: true
    },
    description:{
        type: String,
        required: true
    },
    reviews: {
        type: [Object],
        required: false,
    }
});

module.exports = mongoose.model('VendorData', VendorDataSchema);