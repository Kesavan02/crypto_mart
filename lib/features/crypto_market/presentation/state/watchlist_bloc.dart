import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_watchlist_usecase.dart';
import '../../domain/usecases/toggle_watchlist_usecase.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchlistEvent extends WatchlistEvent {}

class ToggleWatchlistEvent extends WatchlistEvent {
  final String coinId;

  const ToggleWatchlistEvent(this.coinId);

  @override
  List<Object?> get props => [coinId];
}

class WatchlistState extends Equatable {
  final List<String> watchlistIds;
  final bool isLoading;

  const WatchlistState({
    required this.watchlistIds,
    this.isLoading = false,
  });

  bool isWatched(String coinId) => watchlistIds.contains(coinId);

  @override
  List<Object?> get props => [watchlistIds, isLoading];
}

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlistUseCase getWatchlistUseCase;
  final ToggleWatchlistUseCase toggleWatchlistUseCase;

  WatchlistBloc({
    required this.getWatchlistUseCase,
    required this.toggleWatchlistUseCase,
  }) : super(const WatchlistState(watchlistIds: [])) {
    on<LoadWatchlistEvent>(_onLoadWatchlist);
    on<ToggleWatchlistEvent>(_onToggleWatchlist);
  }

  Future<void> _onLoadWatchlist(
    LoadWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    final ids = await getWatchlistUseCase();
    emit(WatchlistState(watchlistIds: ids));
  }

  Future<void> _onToggleWatchlist(
    ToggleWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    await toggleWatchlistUseCase(event.coinId);
    final updatedIds = await getWatchlistUseCase();
    emit(WatchlistState(watchlistIds: updatedIds));
  }
}
