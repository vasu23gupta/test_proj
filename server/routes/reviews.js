const express = require('express');
//var fs = require('fs');
const router = express.Router();
const Review = require('../models/Review');

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
        res.json({message: err});
    }
});

//add review
router.post('/', async (req, res) => {
    const review = new Review({
        by: req.body.by,
        review: req.body.review,
        stars: req.body.stars
    });

    try {
        const savedReview = await review.save();
        res.json(savedReview);
    } catch (err) {
        res.json({ message: err });
    }
});

//delete review
router.delete('/:reviewId', async (req, res) => {
    try {
        const removedReview = await Vendor.deleteOne({ _id: req.params.reviewId });
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
                reviews: reviews.add(req.body.Review),

            }
        });
        res.json(updatedDataVendor);
    } catch (err) {
        res.json({ message: err });
    }
});

module.exports = router;