/**
 * Test suite for Grade 8 PIN-based authentication, rate-limiting, and security fixes.
 * Run with: node tests/auth_pin_test.js
 */

import http from 'http';
import app from '../src/server.js';

let server;
let baseUrl;

function post(endpoint, data, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(endpoint, baseUrl);
    const bodyStr = JSON.stringify(data);
    const req = http.request(
      url,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(bodyStr),
          ...headers,
        },
      },
      (res) => {
        let respData = '';
        res.on('data', (chunk) => (respData += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, data: JSON.parse(respData) });
          } catch (e) {
            resolve({ status: res.statusCode, raw: respData });
          }
        });
      }
    );
    req.on('error', reject);
    req.write(bodyStr);
    req.end();
  });
}

function del(endpoint, data, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(endpoint, baseUrl);
    const bodyStr = JSON.stringify(data);
    const req = http.request(
      url,
      {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(bodyStr),
          ...headers,
        },
      },
      (res) => {
        let respData = '';
        res.on('data', (chunk) => (respData += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, data: JSON.parse(respData) });
          } catch (e) {
            resolve({ status: res.statusCode, raw: respData });
          }
        });
      }
    );
    req.on('error', reject);
    req.write(bodyStr);
    req.end();
  });
}

async function runTests() {
  console.log('--- Starting Backend PIN Auth Test Suite ---');
  let passed = 0;
  let total = 0;

  function assert(condition, name) {
    total++;
    if (condition) {
      console.log(`  ✓ ${name}`);
      passed++;
    } else {
      console.error(`  ✗ FAIL: ${name}`);
    }
  }

  // 1. Signup validation
  const testPhone = `0911${Math.floor(100000 + Math.random() * 900000)}`;
  const signupRes = await post('/api/v1/auth/register', {
    name: 'Caalaa Margaa',
    phone: testPhone,
    schoolZone: 'Shawaa Bahaa',
    schoolName: 'Adaamaa Sad. 1ffaa',
    selectedTrack: 'BOTH',
    pin: '123456',
  });

  assert(signupRes.status === 201, 'Signup creates account with HTTP 201');
  assert(signupRes.data.data.accessToken != null, 'Signup returns short-lived accessToken');
  assert(signupRes.data.data.refreshToken != null, 'Signup returns long-lived refreshToken');
  assert(signupRes.data.data.offlineGraceDays === 21, 'Signup returns OFFLINE_GRACE_DAYS = 21');
  assert(signupRes.data.data.pin == null, 'PIN is never returned in response payload');

  const refreshToken = signupRes.data.data.refreshToken;

  // 2. Online Login with Correct PIN
  const loginSuccess = await post('/api/v1/auth/login', {
    phone: testPhone,
    pin: '123456',
  });
  assert(loginSuccess.status === 200, 'Login with correct PIN returns HTTP 200');
  assert(loginSuccess.data.data.accessToken != null, 'Login returns refreshed accessToken');

  // 3. Online Login with Wrong PIN (Generic error message)
  const loginWrongPin = await post('/api/v1/auth/login', {
    phone: testPhone,
    pin: '999999',
  });
  assert(loginWrongPin.status === 401, 'Login with wrong PIN returns HTTP 401');
  assert(
    loginWrongPin.data.message.includes('Invalid phone number or PIN'),
    'Wrong PIN returns generic message hiding whether phone or PIN is invalid'
  );

  // 4. Online Login with Non-existent Phone
  const loginNonExistent = await post('/api/v1/auth/login', {
    phone: '0999000111',
    pin: '123456',
  });
  assert(loginNonExistent.status === 401, 'Unknown phone returns identical HTTP 401');
  assert(
    loginNonExistent.data.message === loginWrongPin.data.message,
    'Unknown phone returns identical generic message (anti-phone enumeration)'
  );

  // 5. Token Refresh
  const refreshRes = await post('/api/v1/auth/refresh-token', {
    refreshToken,
    phone: testPhone,
  });
  assert(refreshRes.status === 200, 'Refresh token endpoint returns HTTP 200');
  assert(refreshRes.data.accessToken != null, 'Refresh returns valid new accessToken');

  // 6. Admin Temporary Reset Code Generation
  const adminResetRes = await post(
    '/api/v1/auth/admin/generate-reset-code',
    { phone: testPhone },
    { 'X-Admin-Secret': 'lamif_admin_secret_2026' }
  );
  assert(adminResetRes.status === 200, 'Admin reset code generation returns HTTP 200');
  const tempCode = adminResetRes.data.data.temporaryResetCode;
  assert(tempCode != null && tempCode.length === 6, 'Admin receives 6-digit temporary reset code');

  // 7. Student Resets PIN with Temporary Code
  const studentResetRes = await post('/api/v1/auth/reset-pin', {
    phone: testPhone,
    resetCode: tempCode,
    newPin: '654321',
  });
  assert(studentResetRes.status === 200, 'Reset PIN with valid code returns HTTP 200');

  // 8. Single-use check: reusing same reset code fails
  const reuseCodeRes = await post('/api/v1/auth/reset-pin', {
    phone: testPhone,
    resetCode: tempCode,
    newPin: '112233',
  });
  assert(reuseCodeRes.status === 400, 'Reset code is single-use and cannot be reused');

  // 9. Login with new PIN works, old PIN fails
  const oldPinLogin = await post('/api/v1/auth/login', {
    phone: testPhone,
    pin: '123456',
  });
  assert(oldPinLogin.status === 401, 'Old PIN no longer works after reset');

  const newPinLogin = await post('/api/v1/auth/login', {
    phone: testPhone,
    pin: '654321',
  });
  assert(newPinLogin.status === 200, 'New PIN successfully authenticates student');

  // 10. Account Deletion Security: Deletion WITHOUT PIN fails!
  const deleteWithoutPin = await del('/api/v1/auth/delete-account', {
    phone: testPhone,
  });
  assert(
    deleteWithoutPin.status === 400 || deleteWithoutPin.status === 401,
    'Account deletion without PIN is rejected (HTTP 400/401)'
  );

  // 11. Account Deletion Security: Deletion with Wrong PIN fails!
  const deleteWithWrongPin = await del('/api/v1/auth/delete-account', {
    phone: testPhone,
    pin: '000000',
  });
  assert(deleteWithWrongPin.status === 401, 'Account deletion with wrong PIN returns HTTP 401');

  // 12. Account Deletion Security: Deletion with Correct PIN succeeds!
  const deleteSuccess = await del('/api/v1/auth/delete-account', {
    phone: testPhone,
    pin: '654321',
  });
  assert(deleteSuccess.status === 200, 'Account deletion with verified PIN returns HTTP 200');

  // 13. Verifying account is gone after deletion
  const loginAfterDelete = await post('/api/v1/auth/login', {
    phone: testPhone,
    pin: '654321',
  });
  assert(loginAfterDelete.status === 401, 'Deleted account can no longer log in');

  console.log(`\nResults: ${passed}/${total} backend tests passed.`);
  server.close();
  if (passed !== total) process.exit(1);
}

server = app.listen(0, async () => {
  const port = server.address().port;
  baseUrl = `http://127.0.0.1:${port}`;
  try {
    await runTests();
  } catch (e) {
    console.error('Test error:', e);
    server.close();
    process.exit(1);
  }
});
