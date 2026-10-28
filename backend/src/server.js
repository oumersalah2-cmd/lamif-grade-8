import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

import authRoutes from './routes/auth.routes.js';
import syncRoutes from './routes/sync.routes.js';
import prisma from './prisma.js';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 5000;

// Security Middleware (Helmet + Strict CORS)
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' }, // Allows previewing uploaded receipts across domains
  })
);
app.use(
  cors({
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Admin-Secret', 'X-Client-Platform', 'X-Client-Version'],
  })
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded receipts statically for preview
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Serve public assets & account deletion page
app.use(express.static(path.join(__dirname, '../public')));
app.get('/delete-account', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/delete-account.html'));
});
app.get('/privacy-policy', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/privacy-policy.html'));
});

// Health check endpoint for Uptime Kuma, Docker healthcheck, and load balancers
app.get('/health', async (req, res) => {
  let dbStatus = 'unknown';
  try {
    if (prisma) {
      await prisma.$queryRaw`SELECT 1`;
      dbStatus = 'connected';
    }
  } catch (err) {
    dbStatus = `unreachable: ${err.message}`;
  }

  const memoryUsage = process.memoryUsage();

  res.json({
    status: dbStatus === 'connected' ? 'healthy' : 'degraded',
    service: 'Lamif Kutaa 8 Backend API',
    uptimeSeconds: Math.floor(process.uptime()),
    database: dbStatus,
    memory: {
      rssMb: (memoryUsage.rss / 1024 / 1024).toFixed(2),
      heapUsedMb: (memoryUsage.heapUsed / 1024 / 1024).toFixed(2),
    },
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
