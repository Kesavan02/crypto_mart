import '../../../../core/errors/failures.dart';
import '../entities/market_stats_entity.dart';
import '../repositories/crypto_repository.dart';

class GetMarketStatsUseCase {
  final CryptoRepository repository;

  const GetMarketStatsUseCase(this.repository);

  Future<({Failure? failure, MarketStatsEntity? marketStats})> call() {
    return repository.getMarketStats();
  }
}
