const express = require('express');
const router = express.Router();
const relativeController = require('../controllers/relativeController');

router.get('/reports/:elderly_id', relativeController.getResidentReports);

module.exports = router;
