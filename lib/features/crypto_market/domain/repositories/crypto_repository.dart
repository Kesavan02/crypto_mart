import '../../../../core/errors/result.dart';
import '../entities/chart_point_entity.dart';
import '../entities/coin_detail_entity.dart';
import '../entities/coin_entity.dart';
import '../entities/market_stats_entity.dart';

abstract class CryptoRepository {
  Future<Result<List<CoinEntity>>> getCoins({
    String? search,
    String? sortBy,
    String? order,
  });

  Future<Result<CoinDetailEntity>> getCoinDetail(
    String coinId,
  );

  Future<Result<List<ChartPointEntity>>> getCoinChart(
    String coinId, {
    int days = 7,
  });

  Future<Result<MarketStatsEntity>> getMarketStats();

  Future<List<String>> getWatchlistIds();

  Future<bool> toggleWatchlist(String coinId);
}
