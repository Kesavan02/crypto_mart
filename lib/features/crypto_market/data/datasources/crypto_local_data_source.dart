import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coin_model.dart';

abstract class CryptoLocalDataSource {
  Future<List<String>> getWatchlistIds();
  Future<bool> toggleWatchlist(String coinId);
  Future<void> cacheCoins(List<CoinModel> coins);
  Future<List<CoinModel>> getCachedCoins();
}

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
  static const String _watchlistKey = 'CRYPTO_MART_WATCHLIST_IDS';
  static const String _cachedCoinsKey = 'CRYPTO_MART_CACHED_COINS';

  @override
  Future<List<String>> getWatchlistIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_watchlistKey) ?? <String>[];
  }

  @override
  Future<bool> toggleWatchlist(String coinId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = prefs.getStringList(_watchlistKey) ?? <String>[];

    final updatedList = List<String>.from(currentList);
    bool isAdded = false;

    if (updatedList.contains(coinId)) {
      updatedList.remove(coinId);
      isAdded = false;
    } else {
      updatedList.add(coinId);
      isAdded = true;
    }

    await prefs.setStringList(_watchlistKey, updatedList);
    return isAdded;
  }

  @override
  Future<void> cacheCoins(List<CoinModel> coins) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = coins.map((c) => c.toJson()).toList();
    await prefs.setString(_cachedCoinsKey, jsonEncode(jsonList));
  }

  @override
  Future<List<CoinModel>> getCachedCoins() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_cachedCoinsKey);
    if (rawJson == null || rawJson.isEmpty) return <CoinModel>[];
    try {
      final List decoded = jsonDecode(rawJson) as List;
      return decoded
          .map((item) => CoinModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <CoinModel>[];
    }
  }
}
