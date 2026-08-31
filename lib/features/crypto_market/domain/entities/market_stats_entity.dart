import 'package:equatable/equatable.dart';

class MarketStatsEntity extends Equatable {
  final double totalMarketCapUsd;
  final double totalVolume24hUsd;
  final double btcDominance;
  final double ethDominance;
  final int activeCryptocurrencies;
  final double marketCapChangePercentage24h;

  const MarketStatsEntity({
    required this.totalMarketCapUsd,
    required this.totalVolume24hUsd,
    required this.btcDominance,
    required this.ethDominance,
    required this.activeCryptocurrencies,
    required this.marketCapChangePercentage24h,
  });

  @override
  List<Object?> get props => [
        totalMarketCapUsd,
        totalVolume24hUsd,
        btcDominance,
        ethDominance,
        activeCryptocurrencies,
        marketCapChangePercentage24h,
      ];
}
