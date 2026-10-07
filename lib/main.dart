import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/crypto_market/domain/entities/coin_entity.dart';
import 'features/crypto_market/presentation/pages/coin_detail_page.dart';
import 'features/crypto_market/presentation/pages/initial_splash_screen.dart';
import 'features/crypto_market/presentation/state/crypto_list_bloc.dart';
import 'features/crypto_market/presentation/state/watchlist_cubit.dart';
import 'features/settings/presentation/state/settings_cubit.dart';
import 'firebase_options.dart';

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

      // Initialize GetIt dependency injection
      await initDependencies();

      runApp(const CryptoMartApp());
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
  const CryptoMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (_) => sl<SettingsCubit>()..loadSettings(),
        ),
        BlocProvider<CryptoListBloc>(
          create: (_) => sl<CryptoListBloc>(),
        ),
        BlocProvider<WatchlistCubit>(
          create: (_) => sl<WatchlistCubit>(),
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
            home: const InitialSplashScreen(),
          );
        },
      ),
    );
  }
}
