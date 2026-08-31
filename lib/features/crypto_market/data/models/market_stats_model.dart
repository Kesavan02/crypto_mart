import '../../domain/entities/market_stats_entity.dart';

class MarketStatsModel extends MarketStatsEntity {
  const MarketStatsModel({
    required super.totalMarketCapUsd,
    required super.totalVolume24hUsd,
    required super.btcDominance,
    required super.ethDominance,
    required super.activeCryptocurrencies,
    required super.marketCapChangePercentage24h,
  });

  factory MarketStatsModel.fromJson(Map<String, dynamic> json) {
    return MarketStatsModel(
      totalMarketCapUsd:
          (json['total_market_cap_usd'] as num?)?.toDouble() ?? 0.0,
      totalVolume24hUsd:
          (json['total_volume_24h_usd'] as num?)?.toDouble() ?? 0.0,
      btcDominance: (json['btc_dominance'] as num?)?.toDouble() ?? 0.0,
      ethDominance: (json['eth_dominance'] as num?)?.toDouble() ?? 0.0,
      activeCryptocurrencies:
          (json['active_cryptocurrencies'] as num?)?.toInt() ?? 0,
      marketCapChangePercentage24h:
          (json['market_cap_change_percentage_24h'] as num?)?.toDouble() ??
              0.0,
    );
  }
}
