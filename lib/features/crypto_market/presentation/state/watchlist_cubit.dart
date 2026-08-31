import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_watchlist_usecase.dart';
import '../../domain/usecases/toggle_watchlist_usecase.dart';

class WatchlistState extends Equatable {
  final Set<String> watchlistIds;

  const WatchlistState({
    required this.watchlistIds,
  });

  bool isWatched(String coinId) => watchlistIds.contains(coinId);

  WatchlistState copyWith({
    Set<String>? watchlistIds,
  }) {
    return WatchlistState(
      watchlistIds: watchlistIds ?? this.watchlistIds,
    );
  }

  @override
  List<Object?> get props => [watchlistIds];
}

class WatchlistCubit extends Cubit<WatchlistState> {
  final GetWatchlistUseCase getWatchlistUseCase;
  final ToggleWatchlistUseCase toggleWatchlistUseCase;

  WatchlistCubit({
    required this.getWatchlistUseCase,
    required this.toggleWatchlistUseCase,
  }) : super(const WatchlistState(watchlistIds: {}));

  Future<void> loadWatchlist() async {
    final list = await getWatchlistUseCase();
    emit(WatchlistState(watchlistIds: list.toSet()));
  }

  Future<void> toggleWatchlist(String coinId) async {
    await toggleWatchlistUseCase(coinId);
    final updatedList = await getWatchlistUseCase();
    emit(WatchlistState(watchlistIds: updatedList.toSet()));
  }
}
