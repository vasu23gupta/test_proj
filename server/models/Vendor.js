const mongoose = require('mongoose');

// const PointSchema = new mongoose.Schema({
//   type: {
//     type: String,
//     enum: ['Point'],
//     //required: true
//   },
//   coordinates: {
//     type: [Number],
//     required: true
//   }
// });

const VendorSchema = mongoose.Schema({
    name: {
        type: String,
        required: true,
        index: "text"
    },
    location:{
        type: {
          type: String,
          default: 'Point',
        },
        coordinates: {
          type: [Number],
          required: true,
          index: "2dsphere"
        },
    },
    tags: {
        type: String,
        required: true,
        index: "text"
    }
});
VendorSchema.index({name: 'text', 'tags': 'text'});

// const VendorSchema = mongoose.Schema({
//     name: {
//         type: String,
//         required: true
//     },
//     lat: {
//         type: String,
//         required: true
//     },
//     lng: {
//         type: String,
//         required: true
//     },
//     tags: {
//         type: String,
//         required: true
//     }
// })

module.exports = mongoose.model('Vendors', VendorSchema);
//module.exports = mongoose.model('Points', PointSchema);