const express = require('express');
const router = express.Router();
const governmentController = require('../controllers/governmentController');

router.get('/elderly', governmentController.viewAllElderly);
router.get('/reports', governmentController.viewReports);
router.get('/reports/:home_id', governmentController.getDailyReportsByHome);
router.put('/homes/:id/status', governmentController.approveRejectHome);
router.post('/feedback', governmentController.submitFeedback);
router.get('/homes/:id/feedback', governmentController.getFeedbackByHome);

module.exports = router;
