const mongoose = require('mongoose');

const UserSchema = mongoose.Schema({
    _id: {
        type: String,
    },
}, { timestamps: true });

module.exports = mongoose.model('Users', UserSchema);