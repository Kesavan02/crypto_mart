import '../../../../core/errors/result.dart';
import '../entities/market_stats_entity.dart';
import '../repositories/crypto_repository.dart';

class GetMarketStatsUseCase {
  final CryptoRepository repository;

  const GetMarketStatsUseCase(this.repository);

  Future<Result<MarketStatsEntity>> call() {
    return repository.getMarketStats();
  }
}
