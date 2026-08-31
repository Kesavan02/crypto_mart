import '../../../../core/errors/failures.dart';
import '../entities/chart_point_entity.dart';
import '../repositories/crypto_repository.dart';

class GetCoinChartUseCase {
  final CryptoRepository repository;

  const GetCoinChartUseCase(this.repository);

  Future<({Failure? failure, List<ChartPointEntity>? chartPoints})> call(
    String coinId, {
    int days = 7,
  }) {
    return repository.getCoinChart(coinId, days: days);
  }
}
