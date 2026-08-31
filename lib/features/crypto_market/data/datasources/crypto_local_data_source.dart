import 'package:shared_preferences/shared_preferences.dart';

abstract class CryptoLocalDataSource {
  Future<List<String>> getWatchlistIds();
  Future<bool> toggleWatchlist(String coinId);
}

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
  static const String _watchlistKey = 'CRYPTO_MART_WATCHLIST_IDS';

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
}
