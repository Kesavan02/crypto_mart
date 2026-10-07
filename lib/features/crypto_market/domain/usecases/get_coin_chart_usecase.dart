import '../../../../core/errors/result.dart';
import '../entities/chart_point_entity.dart';
import '../repositories/crypto_repository.dart';

class GetCoinChartUseCase {
  final CryptoRepository repository;

  const GetCoinChartUseCase(this.repository);

  Future<Result<List<ChartPointEntity>>> call(
    String coinId, {
    int days = 7,
  }) {
    return repository.getCoinChart(coinId, days: days);
  }
}
