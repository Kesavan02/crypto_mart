import 'package:crypto_mart/core/errors/failures.dart';
import 'package:crypto_mart/core/errors/result.dart';
import 'package:crypto_mart/features/crypto_market/domain/entities/chart_point_entity.dart';
import 'package:crypto_mart/features/crypto_market/domain/entities/coin_detail_entity.dart';
import 'package:crypto_mart/features/crypto_market/domain/entities/coin_entity.dart';
import 'package:crypto_mart/features/crypto_market/domain/entities/market_stats_entity.dart';
import 'package:crypto_mart/features/crypto_market/domain/repositories/crypto_repository.dart';
import 'package:crypto_mart/features/crypto_market/domain/usecases/get_coins_usecase.dart';
import 'package:crypto_mart/features/crypto_market/presentation/state/crypto_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCryptoRepository implements CryptoRepository {
  Result<List<CoinEntity>> resultToReturn = const Success([]);

  @override
  Future<Result<List<CoinEntity>>> getCoins({
    String? search,
    String? sortBy,
    String? order,
  }) async {
    return resultToReturn;
  }

  @override
  Future<Result<CoinDetailEntity>> getCoinDetail(String coinId) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<ChartPointEntity>>> getCoinChart(String coinId,
          {int days = 7}) async =>
      throw UnimplementedError();

  @override
  Future<Result<MarketStatsEntity>> getMarketStats() async =>
      throw UnimplementedError();

  @override
  Future<List<String>> getWatchlistIds() async => [];

  @override
  Future<bool> toggleWatchlist(String coinId) async => true;
}

void main() {
  late CryptoListBloc bloc;
  late MockCryptoRepository mockRepository;

  const tCoin = CoinEntity(
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
    mockRepository = MockCryptoRepository();
    bloc = CryptoListBloc(getCoinsUseCase: GetCoinsUseCase(mockRepository));
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be CryptoListInitialState', () {
    expect(bloc.state, isA<CryptoListInitialState>());
  });

  test(
      'should emit [CryptoListLoadingState, CryptoListLoadedState] when fetch is successful',
      () async {
    mockRepository.resultToReturn = const Success([tCoin]);

    final expectedStates = [
      CryptoListLoadingState(),
      const CryptoListLoadedState(
        coins: [tCoin],
        currentSearch: '',
        currentSortBy: 'market_cap',
      ),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const FetchCryptoListEvent());
  });

  test(
      'should emit [CryptoListLoadingState, CryptoListErrorState] when fetch fails',
      () async {
    mockRepository.resultToReturn =
        const FailureResult(ServerFailure(message: 'Server error'));

    final expectedStates = [
      CryptoListLoadingState(),
      const CryptoListErrorState(errorMessage: 'Server error'),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const FetchCryptoListEvent());
  });
}
