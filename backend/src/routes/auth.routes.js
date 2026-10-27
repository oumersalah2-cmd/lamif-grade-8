import { Router } from 'express';
import { receiptUpload } from '../middleware/upload.js';
import { registerPayment, getPaymentStatus, adminVerifyPayment } from '../controllers/auth.controller.js';

const router = Router();

// POST /api/v1/auth/register-payment - Accepts Multer file upload 'receipt' + form fields
router.post('/register-payment', receiptUpload.single('receipt'), registerPayment);

// GET /api/v1/auth/payment-status - Checks verification status by phone or userId
router.get('/payment-status', getPaymentStatus);

// POST /api/v1/auth/admin-verify - Administrative verification / rejection
router.post('/admin-verify', adminVerifyPayment);

export default router;
