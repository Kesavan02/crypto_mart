const { CACHE_TTL_MS } = require('../config/constants');

class MemoryCache {
  constructor() {
    this.store = new Map();
  }

  get(key) {
    const item = this.store.get(key);
    if (!item) return null;
    if (Date.now() - item.timestamp > item.ttlMs) {
      this.store.delete(key);
      return null;
    }
    return item.data;
  }

  set(key, data, ttlMs = CACHE_TTL_MS) {
    this.store.set(key, {
      timestamp: Date.now(),
      ttlMs,
      data,
    });
  }

  delete(key) {
    this.store.delete(key);
  }

  clear() {
    this.store.clear();
  }
}

module.exports = new MemoryCache();
