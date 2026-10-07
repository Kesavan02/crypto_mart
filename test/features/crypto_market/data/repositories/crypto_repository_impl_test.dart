import 'package:crypto_mart/core/errors/exceptions.dart';
import 'package:crypto_mart/core/errors/failures.dart';
import 'package:crypto_mart/features/crypto_market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_mart/features/crypto_market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_mart/features/crypto_market/data/models/chart_point_model.dart';
import 'package:crypto_mart/features/crypto_market/data/models/coin_detail_model.dart';
import 'package:crypto_mart/features/crypto_market/data/models/coin_model.dart';
import 'package:crypto_mart/features/crypto_market/data/models/market_stats_model.dart';
import 'package:crypto_mart/features/crypto_market/data/repositories/crypto_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRemoteDataSource implements CryptoRemoteDataSource {
  bool shouldFail = false;
  List<CoinModel> coinsToReturn = [];

  @override
  Future<List<CoinModel>> getCoins({
    String? search,
    String? sortBy,
    String? order,
  }) async {
    if (shouldFail) {
      throw const NetworkException(message: 'Network connection error');
    }
    return coinsToReturn;
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) async =>
      throw UnimplementedError();

  @override
  Future<List<ChartPointModel>> getCoinChart(String coinId,
          {int days = 7}) async =>
      throw UnimplementedError();

  @override
  Future<MarketStatsModel> getMarketStats() async =>
      throw UnimplementedError();
}

class MockLocalDataSource implements CryptoLocalDataSource {
  List<CoinModel> cachedCoins = [];
  List<String> watchlistIds = [];

  @override
  Future<void> cacheCoins(List<CoinModel> coins) async {
    cachedCoins = coins;
  }

  @override
  Future<List<CoinModel>> getCachedCoins() async {
    return cachedCoins;
  }

  @override
  Future<List<String>> getWatchlistIds() async => watchlistIds;

  @override
  Future<bool> toggleWatchlist(String coinId) async => true;
}

void main() {
  late CryptoRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  const tCoinModel = CoinModel(
    id: 'bitcoin',
    symbol: 'BTC',
    name: 'Bitcoin',
    imageUrl: '',
    currentPrice: 95000.0,
    marketCap: 1800000000000.0,
    marketCapRank: 1,
    totalVolume: 50000000000.0,
    priceChangePercentage24h: 2.5,
    high24h: 96000.0,
    low24h: 94000.0,
    circulatingSupply: 19700000.0,
    maxSupply: 21000000.0,
    ath: 99000.0,
    sparkline7d: [],
  );

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repository = CryptoRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  test('should return Success with remote data when API call is successful',
      () async {
    mockRemote.coinsToReturn = [tCoinModel];

    final result = await repository.getCoins();

    expect(result.isSuccess, true);
    expect(result.dataOrNull, [tCoinModel]);
    expect(mockLocal.cachedCoins, [tCoinModel]);
  });

  test(
      'should return cached coins when network call fails and cache is available',
      () async {
    mockRemote.shouldFail = true;
    mockLocal.cachedCoins = [tCoinModel];

    final result = await repository.getCoins();

    expect(result.isSuccess, true);
    expect(result.dataOrNull, [tCoinModel]);
  });

  test('should return FailureResult when network call fails and cache is empty',
      () async {
    mockRemote.shouldFail = true;
    mockLocal.cachedCoins = [];

    final result = await repository.getCoins();

    expect(result.isFailure, true);
    expect(result.failureOrNull, isA<NetworkFailure>());
  });
}
