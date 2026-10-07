import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
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
  Future<Result<List<CoinEntity>>> getCoins({
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
      // Cache fetched coins locally for offline access
      await localDataSource.cacheCoins(coins);
      return Success(coins);
    } on NetworkException catch (e) {
      final cachedCoins = await _filterAndSortCachedCoins(
        search: search,
        sortBy: sortBy,
      );
      if (cachedCoins.isNotEmpty) {
        return Success(cachedCoins);
      }
      return FailureResult(NetworkFailure(message: e.message));
    } catch (e) {
      final cachedCoins = await _filterAndSortCachedCoins(
        search: search,
        sortBy: sortBy,
      );
      if (cachedCoins.isNotEmpty) {
        return Success(cachedCoins);
      }
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  Future<List<CoinEntity>> _filterAndSortCachedCoins({
    String? search,
    String? sortBy,
  }) async {
    final cached = await localDataSource.getCachedCoins();
    if (cached.isEmpty) return [];

    Iterable<CoinEntity> filtered = cached;
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      filtered = filtered.where(
        (c) => c.name.toLowerCase().contains(q) || c.symbol.toLowerCase().contains(q),
      );
    }

    final list = filtered.toList();
    if (sortBy == 'price') {
      list.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
    } else if (sortBy == 'change') {
      list.sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
    } else {
      list.sort((a, b) => a.marketCapRank.compareTo(b.marketCapRank));
    }
    return list;
  }

  @override
  Future<Result<CoinDetailEntity>> getCoinDetail(String coinId) async {
    try {
      final coinDetail = await remoteDataSource.getCoinDetail(coinId);
      return Success(coinDetail);
    } on NetworkException catch (e) {
      final fallback = await _getCachedCoinDetailFallback(coinId);
      if (fallback != null) return Success(fallback);
      return FailureResult(NetworkFailure(message: e.message));
    } catch (e) {
      final fallback = await _getCachedCoinDetailFallback(coinId);
      if (fallback != null) return Success(fallback);
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  Future<CoinDetailEntity?> _getCachedCoinDetailFallback(String coinId) async {
    final cached = await localDataSource.getCachedCoins();
    final matching = cached.where((c) => c.id.toLowerCase() == coinId.toLowerCase());
    if (matching.isNotEmpty) {
      final coin = matching.first;
      return CoinDetailEntity(
        id: coin.id,
        symbol: coin.symbol,
        name: coin.name,
        imageUrl: coin.imageUrl,
        description: 'Offline mode: Detailed description unavailable.',
        currentPrice: coin.currentPrice,
        marketCap: coin.marketCap,
        totalVolume: coin.totalVolume,
        priceChangePercentage24h: coin.priceChangePercentage24h,
        high24h: coin.high24h,
        low24h: coin.low24h,
        circulatingSupply: coin.circulatingSupply,
        maxSupply: coin.maxSupply,
        ath: coin.ath,
      );
    }
    return null;
  }

  @override
  Future<Result<List<ChartPointEntity>>> getCoinChart(
    String coinId, {
    int days = 7,
  }) async {
    try {
      final points = await remoteDataSource.getCoinChart(coinId, days: days);
      return Success(points);
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(message: e.message));
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<MarketStatsEntity>> getMarketStats() async {
    try {
      final stats = await remoteDataSource.getMarketStats();
      return Success(stats);
    } on NetworkException catch (e) {
      return FailureResult(NetworkFailure(message: e.message));
    } catch (e) {
      return FailureResult(ServerFailure(message: e.toString()));
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
