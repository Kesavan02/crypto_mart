import 'package:equatable/equatable.dart';

class CoinDetailEntity extends Equatable {
  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final String description;
  final double currentPrice;
  final double marketCap;
  final double totalVolume;
  final double priceChangePercentage24h;
  final double high24h;
  final double low24h;
  final double circulatingSupply;
  final double? maxSupply;
  final double ath;

  const CoinDetailEntity({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.currentPrice,
    required this.marketCap,
    required this.totalVolume,
    required this.priceChangePercentage24h,
    required this.high24h,
    required this.low24h,
    required this.circulatingSupply,
    this.maxSupply,
    required this.ath,
  });

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        imageUrl,
        description,
        currentPrice,
        marketCap,
        totalVolume,
        priceChangePercentage24h,
        high24h,
        low24h,
        circulatingSupply,
        maxSupply,
        ath,
      ];
}
