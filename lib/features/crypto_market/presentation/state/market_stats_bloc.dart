import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/market_stats_entity.dart';
import '../../domain/usecases/get_market_stats_usecase.dart';

abstract class MarketStatsEvent extends Equatable {
  const MarketStatsEvent();

  @override
  List<Object?> get props => [];
}

class FetchMarketStatsEvent extends MarketStatsEvent {
  const FetchMarketStatsEvent();
}

abstract class MarketStatsState extends Equatable {
  const MarketStatsState();

  @override
  List<Object?> get props => [];
}

class MarketStatsInitialState extends MarketStatsState {}

class MarketStatsLoadingState extends MarketStatsState {}

class MarketStatsLoadedState extends MarketStatsState {
  final MarketStatsEntity stats;

  const MarketStatsLoadedState(this.stats);

  @override
  List<Object?> get props => [stats];
}

class MarketStatsErrorState extends MarketStatsState {
  final String message;

  const MarketStatsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class MarketStatsBloc extends Bloc<MarketStatsEvent, MarketStatsState> {
  final GetMarketStatsUseCase getMarketStatsUseCase;

  MarketStatsBloc({required this.getMarketStatsUseCase})
      : super(MarketStatsInitialState()) {
    on<FetchMarketStatsEvent>(_onFetchMarketStats);
  }

  Future<void> _onFetchMarketStats(
    FetchMarketStatsEvent event,
    Emitter<MarketStatsState> emit,
  ) async {
    emit(MarketStatsLoadingState());

    final result = await getMarketStatsUseCase();

    result.fold(
      onSuccess: (stats) {
        emit(MarketStatsLoadedState(stats));
      },
      onFailure: (failure) {
        emit(MarketStatsErrorState(failure.message));
      },
    );
  }
}
