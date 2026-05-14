const express = require('express');
const router = express.Router();
const caretakerController = require('../controllers/caretakerController');

router.post('/elderly', caretakerController.addElderly);
router.put('/elderly/:id/health', caretakerController.updateHealthStatus);
router.get('/:caretaker_id/elderly', caretakerController.viewAssignedElderly);
router.post('/daily-report', caretakerController.addDailyReport);
router.post('/facility-report', caretakerController.addFacilityReport);

module.exports = router;
