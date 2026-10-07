import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/coin_entity.dart';
import '../../domain/usecases/get_coins_usecase.dart';
import '../../domain/usecases/get_watchlist_usecase.dart';
import '../../domain/usecases/toggle_watchlist_usecase.dart';

class WatchlistState extends Equatable {
  final Set<String> watchlistIds;
  final List<CoinEntity> watchedCoins;
  final bool isLoading;
  final String? errorMessage;

  const WatchlistState({
    required this.watchlistIds,
    this.watchedCoins = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  bool isWatched(String coinId) => watchlistIds.contains(coinId);

  WatchlistState copyWith({
    Set<String>? watchlistIds,
    List<CoinEntity>? watchedCoins,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WatchlistState(
      watchlistIds: watchlistIds ?? this.watchlistIds,
      watchedCoins: watchedCoins ?? this.watchedCoins,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        watchlistIds,
        watchedCoins,
        isLoading,
        errorMessage,
      ];
}

class WatchlistCubit extends Cubit<WatchlistState> {
  final GetWatchlistUseCase getWatchlistUseCase;
  final ToggleWatchlistUseCase toggleWatchlistUseCase;
  final GetCoinsUseCase getCoinsUseCase;

  WatchlistCubit({
    required this.getWatchlistUseCase,
    required this.toggleWatchlistUseCase,
    required this.getCoinsUseCase,
  }) : super(const WatchlistState(watchlistIds: {}));

  Future<void> loadWatchlist() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final ids = await getWatchlistUseCase();
    final setIds = ids.toSet();

    if (setIds.isEmpty) {
      emit(WatchlistState(
        watchlistIds: {},
        watchedCoins: const [],
        isLoading: false,
      ));
      return;
    }

    // Fetch coins from repository (remotely or locally cached fallback)
    final coinsResult = await getCoinsUseCase();

    coinsResult.fold(
      onSuccess: (allCoins) {
        final watched = allCoins.where((c) => setIds.contains(c.id)).toList();
        emit(WatchlistState(
          watchlistIds: setIds,
          watchedCoins: watched,
          isLoading: false,
        ));
      },
      onFailure: (failure) {
        emit(state.copyWith(
          watchlistIds: setIds,
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
    );
  }

  Future<void> toggleWatchlist(String coinId) async {
    await toggleWatchlistUseCase(coinId);
    await loadWatchlist();
  }
}
