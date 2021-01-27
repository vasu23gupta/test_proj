const express = require('express');
const router = express.Router();
const User = require('../models/User');

// get all users (for testing)
router.get('/', async (req, res) => {
    try {
        const user = await User.find();
        res.json(user);
    } catch (err) {
        res.json({ message: err });
    }
});

//get one user by id
router.get('/:userId', async (req, res) => {
    try {
        const user = await User.findById(req.params.userId);
        res.json(user);
    } catch (err) {
        res.json({message: err});
    }
});

//add user
router.post('/', async (req, res) => {
    const user = new User({
        _id: req.body.userId
    });

    try {
        const savedUser = await user.save();
        res.json(savedUser);
    } catch (err) {
        res.json({ message: err });
    }
});

//delete user
router.delete('/:userId', async (req, res) => {
    try {
        const removedUser = await User.deleteOne({ _id: req.params.userId });
        res.json(removedUser);
    } catch (err) {
        res.json({ message: err });
    }
});

//update user
router.patch('/:userId', async (req, res) => {
    try {
        const updatedUser = await User.updateOne({ _id: req.params.userId }, {
            $set: {
                //set params
            }
        });
        res.json(updatedUser);
    } catch (err) {
        res.json({ message: err });
    }
});

module.exports = router;