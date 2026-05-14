const express = require('express');
const router = express.Router();
const governmentController = require('../controllers/governmentController');

router.get('/elderly', governmentController.viewAllElderly);
router.get('/reports', governmentController.viewReports);
router.get('/reports/:home_id', governmentController.getDailyReportsByHome);
router.put('/homes/:id/status', governmentController.approveRejectHome);
router.post('/feedback', governmentController.submitFeedback);
router.get('/homes/:id/feedback', governmentController.getFeedbackByHome);
router.get('/facility-reports/:home_id', governmentController.getFacilityReportsByHome);
router.put('/reports/:id/acknowledge', governmentController.acknowledgeReport);
router.put('/homes/:id/inspection', governmentController.scheduleInspection);

module.exports = router;
