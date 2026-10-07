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
    } else if (json['sparkline7d'] != null) {
      sparkline = (json['sparkline7d'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    return CoinModel(
      id: json['id'] ?? '',
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      name: json['name'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      currentPrice: (json['current_price'] ?? json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      marketCap: (json['market_cap'] ?? json['marketCap'] as num?)?.toDouble() ?? 0.0,
      marketCapRank: (json['market_cap_rank'] ?? json['marketCapRank'] as num?)?.toInt() ?? 0,
      totalVolume: (json['total_volume'] ?? json['totalVolume'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] ?? json['priceChangePercentage24h'] as num?)?.toDouble() ?? 0.0,
      high24h: (json['high_24h'] ?? json['high24h'] as num?)?.toDouble() ?? 0.0,
      low24h: (json['low_24h'] ?? json['low24h'] as num?)?.toDouble() ?? 0.0,
      circulatingSupply:
          (json['circulating_supply'] ?? json['circulatingSupply'] as num?)?.toDouble() ?? 0.0,
      maxSupply: (json['max_supply'] ?? json['maxSupply'] as num?)?.toDouble(),
      ath: (json['ath'] as num?)?.toDouble() ?? 0.0,
      sparkline7d: sparkline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'imageUrl': imageUrl,
      'currentPrice': currentPrice,
      'marketCap': marketCap,
      'marketCapRank': marketCapRank,
      'totalVolume': totalVolume,
      'priceChangePercentage24h': priceChangePercentage24h,
      'high24h': high24h,
      'low24h': low24h,
      'circulatingSupply': circulatingSupply,
      'maxSupply': maxSupply,
      'ath': ath,
      'sparkline7d': sparkline7d,
    };
  }
}
