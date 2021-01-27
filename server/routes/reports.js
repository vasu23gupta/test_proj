const express = require('express');
const router = express.Router();
const Report = require('../models/Report');

// get all reports (for testing)
router.get('/', async (req, res) => {
    try {
        const report = await Report.find();
        res.json(report);
    } catch (err) {
        res.json({ message: err });
    }
});

//get one report by id
router.get('/:reportId', async (req, res) => {
    try {
        const report = await Report.findById(req.params.reportId);
        res.json(report);
    } catch (err) {
        res.json({message: err});
    }
});

//add report
router.post('/', async (req, res) => {
    const report = new Report({
        by: req.body.by,
        report: req.body.report,
        vendor: req.body.vendor
    });

    try {
        const savedReport = await report.save();
        res.json(savedReport);
    } catch (err) {
        res.json({ message: err });
    }
});

//delete report
router.delete('/:reportId', async (req, res) => {
    try {
        const removedReport = await Report.deleteOne({ _id: req.params.reportId });
        res.json(removedReport);
    } catch (err) {
        res.json({ message: err });
    }
});

//update report
router.patch('/:reportId', async (req, res) => {
    try {
        const updatedReport = await Report.updateOne({ _id: req.params.reportId }, {
            $set: {
                //set params
                reports: reports.add(req.body.Report),

            }
        });
        res.json(updatedDataVendor);
    } catch (err) {
        res.json({ message: err });
    }
});

module.exports = router;