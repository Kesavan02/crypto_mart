const cryptoService = require('../services/cryptoService');
const cache = require('../utils/cache');

class CryptoController {
  async getCoins(req, res, next) {
    try {
      const { search, sortBy, order } = req.query;
      const cacheKey = `coins_${search || ''}_${sortBy || ''}_${order || ''}`;

      const cachedData = cache.get(cacheKey);
      if (cachedData) {
        return res.json(cachedData);
      }

      const coins = await cryptoService.getCoins({ search, sortBy, order });
      cache.set(cacheKey, coins);
      return res.json(coins);
    } catch (error) {
      next(error);
    }
  }

  async getCoinDetail(req, res, next) {
    try {
      const { id } = req.params;
      const cacheKey = `coin_${id}`;

      const cachedData = cache.get(cacheKey);
      if (cachedData) {
        return res.json(cachedData);
      }

      const coinDetail = await cryptoService.getCoinDetail(id);
      cache.set(cacheKey, coinDetail);
      return res.json(coinDetail);
    } catch (error) {
      next(error);
    }
  }

  async getCoinChart(req, res, next) {
    try {
      const { id } = req.params;
      const days = parseInt(req.query.days) || 7;
      const cacheKey = `chart_${id}_${days}`;

      const cachedData = cache.get(cacheKey);
      if (cachedData) {
        return res.json(cachedData);
      }

      const chartData = await cryptoService.getCoinChart(id, days);
      cache.set(cacheKey, chartData);
      return res.json(chartData);
    } catch (error) {
      next(error);
    }
  }

  async getMarketStats(req, res, next) {
    try {
      const cacheKey = 'global_market_stats';
      const cachedData = cache.get(cacheKey);
      if (cachedData) {
        return res.json(cachedData);
      }

      const stats = await cryptoService.getMarketStats();
      cache.set(cacheKey, stats);
      return res.json(stats);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new CryptoController();
