import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chart_point_entity.dart';
import '../../domain/entities/coin_detail_entity.dart';
import '../../domain/entities/coin_entity.dart';
import '../../domain/entities/market_stats_entity.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../datasources/crypto_local_data_source.dart';
import '../datasources/crypto_remote_data_source.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoRemoteDataSource remoteDataSource;
  final CryptoLocalDataSource localDataSource;

  CryptoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<({Failure? failure, List<CoinEntity>? coins})> getCoins({
    String? search,
    String? sortBy,
    String? order,
  }) async {
    try {
      final coins = await remoteDataSource.getCoins(
        search: search,
        sortBy: sortBy,
        order: order,
      );
      return (failure: null, coins: coins);
    } on NetworkException catch (e) {
      return (
        failure: NetworkFailure(message: e.message),
        coins: null,
      );
    } catch (e) {
      return (
        failure: ServerFailure(message: e.toString()),
        coins: null,
      );
    }
  }

  @override
  Future<({Failure? failure, CoinDetailEntity? coinDetail})> getCoinDetail(
    String coinId,
  ) async {
    try {
      final coinDetail = await remoteDataSource.getCoinDetail(coinId);
      return (failure: null, coinDetail: coinDetail);
    } on NetworkException catch (e) {
      return (
        failure: NetworkFailure(message: e.message),
        coinDetail: null,
      );
    } catch (e) {
      return (
        failure: ServerFailure(message: e.toString()),
        coinDetail: null,
      );
    }
  }

  @override
  Future<({Failure? failure, List<ChartPointEntity>? chartPoints})> getCoinChart(
    String coinId, {
    int days = 7,
  }) async {
    try {
      final points = await remoteDataSource.getCoinChart(coinId, days: days);
      return (failure: null, chartPoints: points);
    } on NetworkException catch (e) {
      return (
        failure: NetworkFailure(message: e.message),
        chartPoints: null,
      );
    } catch (e) {
      return (
        failure: ServerFailure(message: e.toString()),
        chartPoints: null,
      );
    }
  }

  @override
  Future<({Failure? failure, MarketStatsEntity? marketStats})> getMarketStats() async {
    try {
      final stats = await remoteDataSource.getMarketStats();
      return (failure: null, marketStats: stats);
    } on NetworkException catch (e) {
      return (
        failure: NetworkFailure(message: e.message),
        marketStats: null,
      );
    } catch (e) {
      return (
        failure: ServerFailure(message: e.toString()),
        marketStats: null,
      );
    }
  }

  @override
  Future<List<String>> getWatchlistIds() {
    return localDataSource.getWatchlistIds();
  }

  @override
  Future<bool> toggleWatchlist(String coinId) {
    return localDataSource.toggleWatchlist(coinId);
  }
}
