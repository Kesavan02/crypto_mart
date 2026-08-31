import '../../domain/entities/coin_detail_entity.dart';

class CoinDetailModel extends CoinDetailEntity {
  const CoinDetailModel({
    required super.id,
    required super.symbol,
    required super.name,
    required super.imageUrl,
    required super.description,
    required super.currentPrice,
    required super.marketCap,
    required super.totalVolume,
    required super.priceChangePercentage24h,
    required super.high24h,
    required super.low24h,
    required super.circulatingSupply,
    super.maxSupply,
    required super.ath,
  });

  factory CoinDetailModel.fromJson(Map<String, dynamic> json) {
    final marketData = json['market_data'] ?? {};
    final imageObj = json['image'] ?? {};
    final descObj = json['description'] ?? {};

    return CoinDetailModel(
      id: json['id'] ?? '',
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      name: json['name'] ?? '',
      imageUrl: (imageObj is Map ? imageObj['large'] : imageObj.toString()) ?? '',
      description: (descObj is Map ? descObj['en'] : descObj.toString()) ?? '',
      currentPrice:
          (marketData['current_price']?['usd'] as num?)?.toDouble() ?? 0.0,
      marketCap:
          (marketData['market_cap']?['usd'] as num?)?.toDouble() ?? 0.0,
      totalVolume:
          (marketData['total_volume']?['usd'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage24h:
          (marketData['price_change_percentage_24h'] as num?)?.toDouble() ??
              0.0,
      high24h: (marketData['high_24h']?['usd'] as num?)?.toDouble() ?? 0.0,
      low24h: (marketData['low_24h']?['usd'] as num?)?.toDouble() ?? 0.0,
      circulatingSupply:
          (marketData['circulating_supply'] as num?)?.toDouble() ?? 0.0,
      maxSupply: (marketData['max_supply'] as num?)?.toDouble(),
      ath: (marketData['ath']?['usd'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
