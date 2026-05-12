require('dotenv').config();
const express = require('express');
const cors = require('cors');
const routes = require('./routes/index');
const db = require('./database/db_postgres'); // Switched to PostgreSQL (Supabase)

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5000;

// Set up CORS
app.use(cors());

// Simple logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Enable JSON parsing
app.use(express.json());

// Set up routes
app.use('/', routes);

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});
