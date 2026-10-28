import http from 'k6/http';
import { check, sleep } from 'k6';

/**
 * Load test for Lamif Kutaa 8 Backend.
 * Targets a STAGING environment specified via the STAGING_URL environment variable.
 * 
 * Usage:
 *   STAGING_URL=https://staging-api.lamif.org k6 run load_test_staging.js
 *   STAGING_URL=http://localhost:5000 k6 run --vus 50 --duration 1m load_test_staging.js
 */

const BASE_URL = __ENV.STAGING_URL || 'http://localhost:5000';

export const options = {
  stages: [
    { duration: '30s', target: 50 },   // Ramp-up to 50 concurrent students
    { duration: '1m',  target: 250 },  // Surge to 250 concurrent students
    { duration: '2m',  target: 500 },  // Peak load: 500 simultaneous users (pilot scale)
    { duration: '30s', target: 0 },    // Ramp-down
  ],
  thresholds: {
    // 95% of HTTP requests must respond under 450ms on mobile VPS
    http_req_duration: ['p(95)<450'],
    // Error rate must remain under 1%
    http_req_failed: ['rate<0.01'],
  },
};

const SAMPLE_SUBJECTS = ['herrega', 'afaan_oromoo', 'saayinsii_waliigalaa', 'english', 'lammummaa'];

export default function () {
  // Generate random student identifier
  const studentNum = Math.floor(Math.random() * 2000) + 1;
  const phone = `0911${String(studentNum).padStart(6, '0')}`;
  const subject = SAMPLE_SUBJECTS[Math.floor(Math.random() * SAMPLE_SUBJECTS.length)];

  const params = {
    headers: {
      'Content-Type': 'application/json',
      'X-User-Phone': phone, // Real client rate-limit header
      'Accept': 'application/json',
    },
  };

  // 1. Health check probe
  const healthRes = http.get(`${BASE_URL}/health`);
  check(healthRes, {
    'health check is 200': (r) => r.status === 200,
  });

  // 2. Query payment status
  const statusRes = http.get(`${BASE_URL}/api/v1/auth/payment-status?phone=${phone}`, params);
  check(statusRes, {
    'payment status query completed': (r) => r.status === 200 || r.status === 404,
  });

  // 3. Simulate Batch Offline Exam Result & Progress Sync (with realistic validated fields)
  const totalQ = 40;
  const score = Math.floor(Math.random() * 30) + 10; // Plausible score (10 to 40)
  const timeTaken = Math.floor(Math.random() * 1800) + 600; // 10 to 40 minutes

  const syncPayload = JSON.stringify({
    phone: phone,
    examResults: [
      {
        id: Math.floor(Math.random() * 100000),
        subjectId: subject,
        score: score,
        totalQuestions: totalQ,
        timeTaken: timeTaken,
        dateTaken: new Date().toISOString(),
      },
    ],
    userProgress: [
      {
        id: Math.floor(Math.random() * 100000),
        subjectId: subject,
        totalQuestionsAttempted: totalQ,
        totalCorrectAnswers: score,
        totalTimeSpentSeconds: timeTaken,
        lastStudiedAt: new Date().toISOString(),
      },
    ],
  });

  const syncRes = http.post(`${BASE_URL}/api/v1/exams/sync`, syncPayload, params);
  check(syncRes, {
    'sync response is 200': (r) => r.status === 200,
    'sync acknowledged items': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.success === true && Array.isArray(body.syncedExamIds);
      } catch (_) {
        return false;
      }
    },
  });

  // Realistic jittered think time (3 to 8 seconds) between actions
  sleep(Math.random() * 5 + 3);
}
