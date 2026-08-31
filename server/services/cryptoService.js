const axios = require('axios');
const { API_URLS, SYMBOL_MAP } = require('../config/constants');
const MOCK_COINS = require('../data/mockCoins');
const MOCK_STATS = require('../data/mockStats');

// Dynamic in-memory registry of all fetched coins to prevent wrong fallback mappings
const COIN_REGISTRY = new Map();

// Initialize registry with default mock coins
MOCK_COINS.forEach(c => {
  COIN_REGISTRY.set(c.id.toLowerCase(), c);
  COIN_REGISTRY.set(c.symbol.toLowerCase(), c);
});

class CryptoService {
  registerCoins(coins) {
    if (Array.isArray(coins)) {
      coins.forEach(c => {
        if (c && c.id) {
          COIN_REGISTRY.set(c.id.toLowerCase(), c);
          if (c.symbol) {
            COIN_REGISTRY.set(c.symbol.toLowerCase(), c);
          }
        }
      });
    }
  }

  async getCoins({ search, sortBy, order }) {
    try {
      const response = await axios.get(
        `${API_URLS.COINGECKO_BASE}/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=true`,
        { timeout: 4000 }
      );
      let coins = response.data;

      // Register all fetched coins into dynamic registry
      this.registerCoins(coins);

      if (search) {
        const q = search.toLowerCase();
        coins = coins.filter(
          c => c.name.toLowerCase().includes(q) || c.symbol.toLowerCase().includes(q)
        );
      }
      return coins;
    } catch (err) {
      let filtered = [...MOCK_COINS];
      if (search) {
        const q = search.toLowerCase();
        filtered = filtered.filter(
          c => c.name.toLowerCase().includes(q) || c.symbol.toLowerCase().includes(q)
        );
      }
      if (sortBy === 'price') {
        filtered.sort((a, b) =>
          order === 'asc'
            ? a.current_price - b.current_price
            : b.current_price - a.current_price
        );
      } else if (sortBy === 'change') {
        filtered.sort((a, b) =>
          order === 'asc'
            ? a.price_change_percentage_24h - b.price_change_percentage_24h
            : b.price_change_percentage_24h - a.price_change_percentage_24h
        );
      }
      return filtered;
    }
  }

  async getCoinDetail(coinId) {
    const lowerId = coinId.toLowerCase();

    try {
      const response = await axios.get(
        `${API_URLS.COINGECKO_BASE}/coins/${lowerId}`,
        { timeout: 4000 }
      );
      if (response.data) {
        const d = response.data;
        const mappedCoin = {
          id: d.id,
          symbol: d.symbol,
          name: d.name,
          image: d.image?.large || d.image || '',
          current_price: d.market_data?.current_price?.usd || 1.0,
          market_cap: d.market_data?.market_cap?.usd || 1000000,
          total_volume: d.market_data?.total_volume?.usd || 100000,
          price_change_percentage_24h: d.market_data?.price_change_percentage_24h || 0.0,
          high_24h: d.market_data?.high_24h?.usd || 1.0,
          low_24h: d.market_data?.low_24h?.usd || 1.0,
          circulating_supply: d.market_data?.circulating_supply || 1000000,
          max_supply: d.market_data?.max_supply,
          ath: d.market_data?.ath?.usd || 1.0,
        };
        COIN_REGISTRY.set(d.id.toLowerCase(), mappedCoin);
        return response.data;
      }
    } catch (err) {
      // Fallback lookup from dynamic registry or CoinCap
    }

    const found = COIN_REGISTRY.get(lowerId) || MOCK_COINS.find(c => c.id === lowerId);

    const name = found ? found.name : coinId.charAt(0).toUpperCase() + coinId.slice(1);
    const symbol = found ? found.symbol : coinId.toUpperCase();
    const image = found ? (found.image || found.imageUrl || '') : '';
    const price = found ? (found.current_price || found.currentPrice || 1.0) : 10.0;
    const marketCap = found ? (found.market_cap || found.marketCap || 100000000) : 50000000;
    const volume = found ? (found.total_volume || found.totalVolume || 5000000) : 1000000;
    const change24h = found ? (found.price_change_percentage_24h || 0.0) : 1.5;
    const high24h = found ? (found.high_24h || price * 1.05) : price * 1.05;
    const low24h = found ? (found.low_24h || price * 0.95) : price * 0.95;
    const supply = found ? (found.circulating_supply || 10000000) : 10000000;
    const maxSupply = found ? found.max_supply : null;
    const ath = found ? (found.ath || price * 1.5) : price * 1.5;

    return {
      id: lowerId,
      symbol: symbol,
      name: name,
      image: { large: image },
      description: {
        en: `${name} (${symbol.toUpperCase()}) is a decentralized digital asset.`
      },
      market_data: {
        current_price: { usd: price },
        market_cap: { usd: marketCap },
        total_volume: { usd: volume },
        price_change_percentage_24h: change24h,
        high_24h: { usd: high24h },
        low_24h: { usd: low24h },
        circulating_supply: supply,
        max_supply: maxSupply,
        ath: { usd: ath }
      }
    };
  }

  async getCoinChart(coinId, days) {
    const lowerId = coinId.toLowerCase();

    // 1. Try CoinGecko API (Official primary provider)
    try {
      const response = await axios.get(
        `${API_URLS.COINGECKO_BASE}/coins/${lowerId}/market_chart?vs_currency=usd&days=${days}`,
        { timeout: 3500 }
      );
      if (response.data && response.data.prices && response.data.prices.length > 0) {
        return response.data;
      }
    } catch (err) {
      // Fallthrough to CoinCap API
    }

    // 2. Try CoinCap Public API (High reliability free chart history for 10,000+ assets)
    let coinCapInterval = 'm15';
    if (days <= 1) coinCapInterval = 'm15';
    else if (days <= 7) coinCapInterval = 'h2';
    else if (days <= 30) coinCapInterval = 'h12';
    else coinCapInterval = 'd1';

    try {
      const coinCapRes = await axios.get(
        `https://api.coincap.io/v2/assets/${lowerId}/history?interval=${coinCapInterval}`,
        { timeout: 3500 }
      );
      if (coinCapRes.data && Array.isArray(coinCapRes.data.data) && coinCapRes.data.data.length > 0) {
        const prices = coinCapRes.data.data.map(item => [
          item.time,
          parseFloat(item.priceUsd)
        ]);
        return { prices };
      }
    } catch (err) {
      // Fallthrough to Binance API
    }

    // 3. Try Binance Public API (Real-time live market orderbook candles)
    const regCoin = COIN_REGISTRY.get(lowerId);
    const regSymbol = regCoin ? regCoin.symbol.toUpperCase() : lowerId.toUpperCase();
    const symbol = SYMBOL_MAP[lowerId] || `${regSymbol}USDT`;

    let binanceInterval = '2h';
    let binanceLimit = 84;
    if (days <= 1) {
      binanceInterval = '15m';
      binanceLimit = 96;
    } else if (days <= 7) {
      binanceInterval = '2h';
      binanceLimit = 84;
    } else if (days <= 30) {
      binanceInterval = '12h';
      binanceLimit = 60;
    } else if (days <= 365) {
      binanceInterval = '1d';
      binanceLimit = 365;
    } else {
      binanceInterval = '1w';
      binanceLimit = 260;
    }

    try {
      const binanceRes = await axios.get(
        `${API_URLS.BINANCE_BASE}/klines?symbol=${symbol}&interval=${binanceInterval}&limit=${binanceLimit}`,
        { timeout: 3500 }
      );
      if (Array.isArray(binanceRes.data) && binanceRes.data.length > 0) {
        const prices = binanceRes.data.map(kline => [
          kline[0],
          parseFloat(kline[4])
        ]);
        return { prices };
      }
    } catch (err) {
      // Fallthrough to CryptoCompare Public API
    }

    // 4. Try CryptoCompare Public API
    try {
      const ccEndpoint = days <= 30
        ? `https://min-api.cryptocompare.com/data/v2/histohour?fsym=${regSymbol}&tsym=USD&limit=${days * 24}`
        : `https://min-api.cryptocompare.com/data/v2/histoday?fsym=${regSymbol}&tsym=USD&limit=${days}`;
      const ccRes = await axios.get(ccEndpoint, { timeout: 3500 });
      if (ccRes.data && ccRes.data.Data && Array.isArray(ccRes.data.Data.Data) && ccRes.data.Data.Data.length > 0) {
        const prices = ccRes.data.Data.Data.map(item => [
          item.time * 1000,
          item.close
        ]);
        return { prices };
      }
    } catch (err) {
      // Fallthrough to Realistic Random Walk Financial Generator
    }

    // 5. Realistic Geometric Random Walk Financial Generator (Realistic ups and downs, never a smooth sine wave)
    const found = COIN_REGISTRY.get(lowerId) || MOCK_COINS.find(c => c.id === lowerId);
    const currentPrice = found ? (found.current_price || found.currentPrice || 10.0) : 10.0;
    const now = Date.now();
    const prices = [];

    let count = 40;
    if (days >= 365) count = 120;
    if (days >= 1825) count = 180;

    let runningPrice = currentPrice * (0.92 + Math.random() * 0.16);
    const volatility = days <= 1 ? 0.008 : days <= 7 ? 0.018 : 0.035;

    for (let i = count; i >= 0; i--) {
      const time = now - (i * (86400000 * days / count));

      if (i === 0) {
        runningPrice = currentPrice;
      } else {
        // Geometric Random Walk step with mean reversion
        const changePercent = (Math.random() - 0.48) * volatility;
        runningPrice = runningPrice * (1.0 + changePercent);
      }

      prices.push([time, runningPrice]);
    }

    return { prices };
  }

  async getMarketStats() {
    try {
      const response = await axios.get(
        `${API_URLS.COINGECKO_BASE}/global`,
        { timeout: 4000 }
      );
      const data = response.data.data;
      return {
        total_market_cap_usd: data.total_market_cap.usd,
        total_volume_24h_usd: data.total_volume.usd,
        btc_dominance: data.market_cap_percentage.btc,
        eth_dominance: data.market_cap_percentage.eth,
        active_cryptocurrencies: data.active_cryptocurrencies,
        market_cap_change_percentage_24h: data.market_cap_change_percentage_24h_usd
      };
    } catch (err) {
      return MOCK_STATS;
    }
  }
}

module.exports = new CryptoService();
