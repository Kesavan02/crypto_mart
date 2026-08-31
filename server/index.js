const express = require('express');
const cors = require('cors');
const { PORT } = require('./config/constants');
const cryptoRoutes = require('./routes/cryptoRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Health Check Routes for Render & Load Balancers
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    service: 'crypto-mart-backend',
    message: 'CryptoMart API Proxy Server is live on Render!',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// API Routes
app.use('/api', cryptoRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Server Exception:', err);
  res.status(500).json({ error: 'Internal Server Error', message: err.message });
});

app.listen(PORT, () => {
  console.log(`CryptoMart Node.js API Server running on port ${PORT}`);
});
