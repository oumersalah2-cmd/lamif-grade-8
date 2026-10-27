import { Router } from 'express';
import { syncOfflineRecords } from '../controllers/sync.controller.js';

const router = Router();

// POST /api/v1/exams/sync
router.post('/sync', syncOfflineRecords);
router.post('/sync-results', syncOfflineRecords);

export default router;
