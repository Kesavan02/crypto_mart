try {
  require('dotenv').config();
} catch (e) {
  // Gracefully fallback if dotenv module is not installed in production environment (Render injects process.env natively)
}

const PORT = process.env.PORT || 3000;
const CACHE_TTL_MS = 60 * 1000; // 60 Seconds

const API_URLS = {
  COINGECKO_BASE: process.env.COINGECKO_BASE_URL,
  BINANCE_BASE: process.env.BINANCE_BASE_URL,
};

const SYMBOL_MAP = {
  bitcoin: 'BTCUSDT',
  ethereum: 'ETHUSDT',
  solana: 'SOLUSDT',
  ripple: 'XRPUSDT',
  cardano: 'ADAUSDT',
  dogecoin: 'DOGEUSDT',
  binancecoin: 'BNBUSDT',
  'avalanche-2': 'AVAXUSDT',
  'shiba-inu': 'SHIBUSDT',
  polkadot: 'DOTUSDT',
  chainlink: 'LINKUSDT',
  polygon: 'MATICUSDT',
  near: 'NEARUSDT',
  uniswap: 'UNIUSDT',
  litecoin: 'LTCUSDT',
  pepe: 'PEPEUSDT',
  sui: 'SUIUSDT',
  aptos: 'APTUSDT',
};

module.exports = {
  PORT,
  CACHE_TTL_MS,
  API_URLS,
  SYMBOL_MAP,
};
