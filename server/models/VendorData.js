const mongoose = require('mongoose');

const VendorDataSchema = mongoose.Schema({
    images: {
        type: [String],
        required: true
    },
});

module.exports = mongoose.model('VendorData', VendorDataSchema);