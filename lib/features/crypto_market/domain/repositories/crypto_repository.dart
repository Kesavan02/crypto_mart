import '../../../../core/errors/failures.dart';
import '../entities/chart_point_entity.dart';
import '../entities/coin_detail_entity.dart';
import '../entities/coin_entity.dart';
import '../entities/market_stats_entity.dart';

abstract class CryptoRepository {
  Future<({Failure? failure, List<CoinEntity>? coins})> getCoins({
    String? search,
    String? sortBy,
    String? order,
  });

  Future<({Failure? failure, CoinDetailEntity? coinDetail})> getCoinDetail(
    String coinId,
  );

  Future<({Failure? failure, List<ChartPointEntity>? chartPoints})> getCoinChart(
    String coinId, {
    int days = 7,
  });

  Future<({Failure? failure, MarketStatsEntity? marketStats})> getMarketStats();

  Future<List<String>> getWatchlistIds();

  Future<bool> toggleWatchlist(String coinId);
}
