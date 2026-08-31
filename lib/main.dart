import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_update_gate.dart';
import 'features/crypto_market/data/datasources/crypto_local_data_source.dart';
import 'features/crypto_market/data/datasources/crypto_remote_data_source.dart';
import 'features/crypto_market/data/repositories/crypto_repository_impl.dart';
import 'features/crypto_market/domain/entities/coin_entity.dart';
import 'features/crypto_market/domain/usecases/get_coin_chart_usecase.dart';
import 'features/crypto_market/domain/usecases/get_coin_detail_usecase.dart';
import 'features/crypto_market/domain/usecases/get_coins_usecase.dart';
import 'features/crypto_market/domain/usecases/get_watchlist_usecase.dart';
import 'features/crypto_market/domain/usecases/toggle_watchlist_usecase.dart';
import 'features/crypto_market/presentation/pages/coin_detail_page.dart';
import 'features/crypto_market/presentation/pages/main_navigation_page.dart';
import 'features/crypto_market/presentation/state/coin_detail_bloc.dart';
import 'features/crypto_market/presentation/state/crypto_list_bloc.dart';
import 'features/crypto_market/presentation/state/watchlist_cubit.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'features/settings/presentation/state/settings_cubit.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final isCrashlyticsSupported = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);

      if (isCrashlyticsSupported) {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;

        PlatformDispatcher.instance.onError =
            (Object error, StackTrace stackTrace) {
          FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            fatal: true,
          );
          return true;
        };
      } else {
        FlutterError.onError = FlutterError.dumpErrorToConsole;
        PlatformDispatcher.instance.onError =
            (Object error, StackTrace stackTrace) {
          debugPrint('Uncaught error: $error\n$stackTrace');
          return true;
        };
      }

      final dioClient = DioClient();
      final remoteDataSource =
          CryptoRemoteDataSourceImpl(client: dioClient.instance);
      final localDataSource = CryptoLocalDataSourceImpl();
      final repository = CryptoRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
      );

      runApp(
        CryptoMartApp(
          repository: repository,
        ),
      );
    },
    (Object error, StackTrace stackTrace) {
      final isCrashlyticsSupported = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);
      if (isCrashlyticsSupported) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: true,
        );
      } else {
        debugPrint('Zoned error: $error\n$stackTrace');
      }
    },
  );
}

class CryptoMartApp extends StatelessWidget {
  final CryptoRepositoryImpl repository;

  const CryptoMartApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit()..loadSettings(),
        ),
        BlocProvider<CryptoListBloc>(
          create: (_) => CryptoListBloc(
            getCoinsUseCase: GetCoinsUseCase(repository),
          ),
        ),
        BlocProvider<CoinDetailBloc>(
          create: (_) => CoinDetailBloc(
            getCoinDetailUseCase: GetCoinDetailUseCase(repository),
            getCoinChartUseCase: GetCoinChartUseCase(repository),
          ),
        ),
        BlocProvider<WatchlistCubit>(
          create: (_) => WatchlistCubit(
            getWatchlistUseCase: GetWatchlistUseCase(repository),
            toggleWatchlistUseCase: ToggleWatchlistUseCase(repository),
          ),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'CryptoMart',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.themeMode,
            onGenerateRoute: (settings) {
              if (settings.name == '/coin_detail') {
                final coin = settings.arguments as CoinEntity?;
                return MaterialPageRoute(
                  builder: (_) => CoinDetailPage(
                    coinEntity: coin,
                    coinId: coin?.id,
                  ),
                );
              }
              return null;
            },
            home: const AppUpdateGate(
              child: MainNavigationPage(),
            ),
          );
        },
      ),
    );
  }
}
