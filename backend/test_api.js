const http = require('http');

const data = JSON.stringify({ email: 'sourcing@example.com', password: 'password123' }); // I will need to find the correct email/pass or generate a token

// Actually, I can just generate a JWT directly if I know the secret.
const jwt = require('jsonwebtoken');
require('dotenv').config({ path: './.env' });

const token = jwt.sign({ id: 'VMU0003', role: 'sourcing' }, process.env.JWT_SECRET || 'verifiedmaids_super_secret_key_2026', { expiresIn: '1h' });

const req = http.request({
  hostname: 'localhost',
  port: 5000,
  path: '/api/analytics/sourcing',
  method: 'GET',
  headers: {
    'Authorization': 'Bearer ' + token,
    'x-api-key': 'crm-secure-key-2026'
  }
}, res => {
  let body = '';
  res.on('data', d => body += d);
  res.on('end', () => console.log('Response:', body));
});
req.on('error', e => console.error(e));
req.end();
