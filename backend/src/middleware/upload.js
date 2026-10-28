import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Ensure upload directory exists
const uploadDir = path.join(__dirname, '../../uploads/receipts');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Storage configuration with sanitized timestamp naming
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const phone = req.body.phone ? req.body.phone.replace(/[^0-9]/g, '') : 'receipt';
    const timestamp = Date.now();
    const ext = path.extname(file.originalname).toLowerCase() || '.jpg';
    cb(null, `${phone}_${timestamp}${ext}`);
  },
});

// File filter to allow only image screenshots
const fileFilter = (req, file, cb) => {
  const allowedMimes = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/jpg'];
  if (allowedMimes.includes(file.mimetype.toLowerCase())) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file format. Please upload a valid image screenshot (JPG, PNG, WebP).'), false);
  }
};

export const receiptUpload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit optimal for mobile receipts without exhausting VPS disk
  },
  fileFilter,
});
