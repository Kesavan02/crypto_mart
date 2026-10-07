import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../../features/crypto_market/data/datasources/crypto_local_data_source.dart';
import '../../features/crypto_market/data/datasources/crypto_remote_data_source.dart';
import '../../features/crypto_market/data/repositories/crypto_repository_impl.dart';
import '../../features/crypto_market/domain/repositories/crypto_repository.dart';
import '../../features/crypto_market/domain/usecases/get_coin_chart_usecase.dart';
import '../../features/crypto_market/domain/usecases/get_coin_detail_usecase.dart';
import '../../features/crypto_market/domain/usecases/get_coins_usecase.dart';
import '../../features/crypto_market/domain/usecases/get_market_stats_usecase.dart';
import '../../features/crypto_market/domain/usecases/get_watchlist_usecase.dart';
import '../../features/crypto_market/domain/usecases/toggle_watchlist_usecase.dart';
import '../../features/crypto_market/presentation/state/coin_detail_bloc.dart';
import '../../features/crypto_market/presentation/state/crypto_list_bloc.dart';
import '../../features/crypto_market/presentation/state/market_stats_bloc.dart';
import '../../features/crypto_market/presentation/state/watchlist_cubit.dart';
import '../../features/settings/presentation/state/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Data Sources
  sl.registerLazySingleton<CryptoRemoteDataSource>(
    () => CryptoRemoteDataSourceImpl(client: sl<DioClient>().instance),
  );
  sl.registerLazySingleton<CryptoLocalDataSource>(
    () => CryptoLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<CryptoRepository>(
    () => CryptoRepositoryImpl(
      remoteDataSource: sl<CryptoRemoteDataSource>(),
      localDataSource: sl<CryptoLocalDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCoinsUseCase(sl<CryptoRepository>()));
  sl.registerLazySingleton(() => GetCoinDetailUseCase(sl<CryptoRepository>()));
  sl.registerLazySingleton(() => GetCoinChartUseCase(sl<CryptoRepository>()));
  sl.registerLazySingleton(() => GetMarketStatsUseCase(sl<CryptoRepository>()));
  sl.registerLazySingleton(() => GetWatchlistUseCase(sl<CryptoRepository>()));
  sl.registerLazySingleton(() => ToggleWatchlistUseCase(sl<CryptoRepository>()));

  // Blocs / Cubits
  sl.registerLazySingleton(
    () => SettingsCubit(sl<SharedPreferences>()),
  );

  sl.registerFactory(
    () => CryptoListBloc(getCoinsUseCase: sl<GetCoinsUseCase>()),
  );

  sl.registerFactory(
    () => WatchlistCubit(
      getWatchlistUseCase: sl<GetWatchlistUseCase>(),
      toggleWatchlistUseCase: sl<ToggleWatchlistUseCase>(),
      getCoinsUseCase: sl<GetCoinsUseCase>(),
    ),
  );

  sl.registerFactory(
    () => MarketStatsBloc(getMarketStatsUseCase: sl<GetMarketStatsUseCase>()),
  );

  sl.registerFactory(
    () => CoinDetailBloc(
      getCoinDetailUseCase: sl<GetCoinDetailUseCase>(),
      getCoinChartUseCase: sl<GetCoinChartUseCase>(),
    ),
  );
}
