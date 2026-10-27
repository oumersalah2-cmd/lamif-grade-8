import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

import authRoutes from './routes/auth.routes.js';
import syncRoutes from './routes/sync.routes.js';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded receipts statically for preview
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'Lamif Kutaa 8 Backend API',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/exams', syncRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err);
  if (err.name === 'MulterError') {
    return res.status(400).json({
      success: false,
      message: `File upload error: ${err.message}`,
    });
  }
  return res.status(500).json({
    success: false,
    message: err.message || 'Internal Server Error',
  });
});

// Start listening if run directly
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`===============================================`);
    console.log(` Lamif Kutaa 8 Prep Backend running on port ${PORT}`);
    console.log(` PostgreSQL Connection configured via Prisma`);
    console.log(` Endpoint: POST /api/v1/auth/register-payment`);
    console.log(` Endpoint: GET  /api/v1/auth/payment-status`);
    console.log(` Endpoint: POST /api/v1/exams/sync`);
    console.log(`===============================================`);
  });
}

export default app;
