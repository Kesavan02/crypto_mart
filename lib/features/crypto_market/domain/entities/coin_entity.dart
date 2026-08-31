import 'package:equatable/equatable.dart';

class CoinEntity extends Equatable {
  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;
  final double priceChangePercentage24h;
  final double high24h;
  final double low24h;
  final double circulatingSupply;
  final double? maxSupply;
  final double ath;
  final List<double> sparkline7d;

  const CoinEntity({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.priceChangePercentage24h,
    required this.high24h,
    required this.low24h,
    required this.circulatingSupply,
    this.maxSupply,
    required this.ath,
    required this.sparkline7d,
  });

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        imageUrl,
        currentPrice,
        marketCap,
        marketCapRank,
        totalVolume,
        priceChangePercentage24h,
        high24h,
        low24h,
        circulatingSupply,
        maxSupply,
        ath,
        sparkline7d,
      ];
}
