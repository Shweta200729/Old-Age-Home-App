const express = require('express');
const router = express.Router();
const indexController = require('../controllers/indexController');
const authRoute = require('./authRoute');
const caretakerRoute = require('./caretakerRoute');
const governmentRoute = require('./governmentRoute');
const adminRoute = require('./adminRoute');
const homeRoute = require('./homeRoute'); // [NEW]
const relativeRoute = require('./relativeRoute'); // [NEW]

// Health check for Render deployment
router.get('/api/health', (req, res) => res.status(200).json({ status: 'ok', database: 'connected' }));

// Root route
router.get('/', indexController.getRoot);

// API routes
router.use('/api/auth', authRoute);
router.use('/api/caretaker', caretakerRoute);
router.use('/api/government', governmentRoute);
router.use('/api/admin', adminRoute);
router.use('/api/homes', homeRoute); // [NEW]
router.use('/api/relative', relativeRoute); // [NEW]

module.exports = router;
