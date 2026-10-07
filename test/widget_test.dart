import 'package:crypto_mart/core/di/injection_container.dart';
import 'package:crypto_mart/features/crypto_market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_mart/features/crypto_market/data/models/chart_point_model.dart';
import 'package:crypto_mart/features/crypto_market/data/models/coin_detail_model.dart';
import 'package:crypto_mart/features/crypto_market/data/models/coin_model.dart';
import 'package:crypto_mart/features/crypto_market/data/models/market_stats_model.dart';
import 'package:crypto_mart/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTestRemoteDataSource implements CryptoRemoteDataSource {
  @override
  Future<List<CoinModel>> getCoins(
          {String? search, String? sortBy, String? order}) async =>
      [];

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) async =>
      throw UnimplementedError();

  @override
  Future<List<ChartPointModel>> getCoinChart(String coinId,
          {int days = 7}) async =>
      [];

  @override
  Future<MarketStatsModel> getMarketStats() async => const MarketStatsModel(
        totalMarketCapUsd: 1000,
        totalVolume24hUsd: 100,
        btcDominance: 50,
        ethDominance: 20,
        activeCryptocurrencies: 5000,
        marketCapChangePercentage24h: 1.0,
      );
}

void main() {
  testWidgets('CryptoMartApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();

    if (sl.isRegistered<CryptoRemoteDataSource>()) {
      sl.unregister<CryptoRemoteDataSource>();
    }
    sl.registerLazySingleton<CryptoRemoteDataSource>(
        () => MockTestRemoteDataSource());

    await tester.pumpWidget(const CryptoMartApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CryptoMartApp), findsOneWidget);
  });
}
