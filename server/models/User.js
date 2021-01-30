const mongoose = require('mongoose');

const UserSchema = mongoose.Schema({
    _id: {
        type: String,
    },
    vendors: {
        type: [String],
    },
    reviews: {
        type: [String],
    },
}, { timestamps: true });

module.exports = mongoose.model('Users', UserSchema);