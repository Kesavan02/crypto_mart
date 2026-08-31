import '../../domain/entities/coin_entity.dart';

class CoinModel extends CoinEntity {
  const CoinModel({
    required super.id,
    required super.symbol,
    required super.name,
    required super.imageUrl,
    required super.currentPrice,
    required super.marketCap,
    required super.marketCapRank,
    required super.totalVolume,
    required super.priceChangePercentage24h,
    required super.high24h,
    required super.low24h,
    required super.circulatingSupply,
    super.maxSupply,
    required super.ath,
    required super.sparkline7d,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    List<double> sparkline = [];
    if (json['sparkline_in_7d'] != null &&
        json['sparkline_in_7d']['price'] != null) {
      sparkline = (json['sparkline_in_7d']['price'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    return CoinModel(
      id: json['id'] ?? '',
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      name: json['name'] ?? '',
      imageUrl: json['image'] ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt() ?? 0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0.0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0.0,
      circulatingSupply:
          (json['circulating_supply'] as num?)?.toDouble() ?? 0.0,
      maxSupply: (json['max_supply'] as num?)?.toDouble(),
      ath: (json['ath'] as num?)?.toDouble() ?? 0.0,
      sparkline7d: sparkline,
    );
  }
}
