const mongoose = require('mongoose');

const ReviewSchema = mongoose.Schema({
    stars: {
        type: Number,
        required: true
    },
    by:{
        type: String,
        required: true
    },
    review: {
        type: String,
        required: true,
    }
});

module.exports = mongoose.model('Review', ReviewSchema);