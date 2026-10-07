import 'package:crypto_mart/features/crypto_market/data/models/coin_model.dart';
import 'package:crypto_mart/features/crypto_market/domain/entities/coin_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tCoinModel = CoinModel(
    id: 'bitcoin',
    symbol: 'BTC',
    name: 'Bitcoin',
    imageUrl: 'https://example.com/btc.png',
    currentPrice: 95000.0,
    marketCap: 1800000000000.0,
    marketCapRank: 1,
    totalVolume: 50000000000.0,
    priceChangePercentage24h: 2.5,
    high24h: 96000.0,
    low24h: 94000.0,
    circulatingSupply: 19700000.0,
    maxSupply: 21000000.0,
    ath: 99000.0,
    sparkline7d: [94000.0, 95000.0],
  );

  test('should be a subclass of CoinEntity', () {
    expect(tCoinModel, isA<CoinEntity>());
  });

  group('fromJson', () {
    test('should return a valid CoinModel from API JSON', () {
      final Map<String, dynamic> jsonMap = {
        'id': 'bitcoin',
        'symbol': 'btc',
        'name': 'Bitcoin',
        'image': 'https://example.com/btc.png',
        'current_price': 95000.0,
        'market_cap': 1800000000000.0,
        'market_cap_rank': 1,
        'total_volume': 50000000000.0,
        'price_change_percentage_24h': 2.5,
        'high_24h': 96000.0,
        'low_24h': 94000.0,
        'circulating_supply': 19700000.0,
        'max_supply': 21000000.0,
        'ath': 99000.0,
        'sparkline_in_7d': {
          'price': [94000.0, 95000.0]
        }
      };

      final result = CoinModel.fromJson(jsonMap);

      expect(result.id, 'bitcoin');
      expect(result.symbol, 'BTC');
      expect(result.currentPrice, 95000.0);
      expect(result.sparkline7d.length, 2);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      final result = tCoinModel.toJson();

      final expectedMap = {
        'id': 'bitcoin',
        'symbol': 'BTC',
        'name': 'Bitcoin',
        'imageUrl': 'https://example.com/btc.png',
        'currentPrice': 95000.0,
        'marketCap': 1800000000000.0,
        'marketCapRank': 1,
        'totalVolume': 50000000000.0,
        'priceChangePercentage24h': 2.5,
        'high24h': 96000.0,
        'low24h': 94000.0,
        'circulatingSupply': 19700000.0,
        'maxSupply': 21000000.0,
        'ath': 99000.0,
        'sparkline7d': [94000.0, 95000.0],
      };

      expect(result, expectedMap);
    });
  });
}
