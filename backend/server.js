require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const helmet = require('helmet');
const apiKeyMiddleware = require('./middleware/apiKeyMiddleware');

// Initialize Express App
const app = express();

// Middleware
app.use(helmet({ crossOriginResourcePolicy: false })); // Basic HTTP headers security, crossOriginResourcePolicy false to allow images
app.use(cors());
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true }));

// Global API Key Protection
app.use(apiKeyMiddleware);

// Static folder for uploaded images
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Test Database Connection (just to log on startup)
const pool = require('./config/db');

// Basic Route for testing
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to the CRM API.' });
});

// --- Routes ---
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/clients', require('./routes/clientRoutes'));
app.use('/api/candidates', require('./routes/candidateRoutes'));
app.use('/api/contracts', require('./routes/contractRoutes'));
app.use('/api/tasks', require('./routes/taskRoutes'));
app.use('/api/replacements', require('./routes/replacementRoutes'));
app.use('/api/analytics', require('./routes/analyticsRoutes'));
app.use('/api/audit-logs', require('./routes/auditLogRoutes'));
app.use('/api/search', require('./routes/searchRoutes'));
app.use('/api/tickets', require('./routes/ticketRoutes'));
// ---------------------------------

// Error Handling Middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!', details: err.message });
});

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
