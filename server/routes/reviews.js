const express = require('express');
const router = express.Router();
const Review = require('../models/Review');
const User = require('../models/User');
const Vendor = require('../models/Vendor');

// get all reviews (for testing)
router.get('/', async (req, res) => {
    try {
        const review = await Review.find();
        res.json(review);
    } catch (err) {
        res.json({ message: err });
    }
});

//get one review by id
router.get('/:reviewId', async (req, res) => {
    try {
        const review = await Review.findById(req.params.reviewId);
        res.json(review);
    } catch (err) {
        res.json({ message: err });
    }
});

//add review
router.post('/', async (req, res) => {
    const review = new Review({
        by: req.body.by,
        review: req.body.review,
        stars: req.body.stars,
        vendorId: req.body.vendorId,
    });

    try {
        const savedReview = await review.save();
        const updatedUser = await User.updateOne({ _id: req.body.by }, {
            $push: {
                reviews: savedReview._id
            },
        });
        var updatedVendor = await Vendor.updateOne({ _id: req.body.vendorId }, {
            $push: {
                reviews: savedReview._id
            },
            $inc: { totalReviews: 1, totalStars: savedReview.stars },
        });
        var vendor = await Vendor.findById(req.body.vendorId, { totalReviews: 1, totalStars: 1, _id: 0 });
        const totalReviews = vendor.totalReviews;
        const totalStars = vendor.totalStars;
        var rating = totalStars / totalReviews;
        rating = Math.round((rating + Number.EPSILON) * 100) / 100

        var updatedVendor = await Vendor.updateOne({ _id: req.body.vendorId }, {
            $set: { rating: rating }
        });
        res.json(savedReview);
    } catch (err) {
        res.json({ message: err });
    }
});

//delete review, not in use rn
router.delete('/:reviewId', async (req, res) => {
    try {
        const removedReview = await Review.deleteOne({ _id: req.params.reviewId });
        res.json(removedReview);
    } catch (err) {
        res.json({ message: err });
    }
});

//update review
router.patch('/:reviewId', async (req, res) => {
    try {
        const updatedReview = await Review.updateOne({ _id: req.params.reviewId }, {
            $set: {
                //set params
            }
        });
        res.json(updatedDataVendor);
    } catch (err) {
        res.json({ message: err });
    }
});

module.exports = router;