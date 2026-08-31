import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chart_point_entity.dart';
import '../../domain/entities/coin_detail_entity.dart';
import '../../domain/usecases/get_coin_chart_usecase.dart';
import '../../domain/usecases/get_coin_detail_usecase.dart';

abstract class CoinDetailEvent extends Equatable {
  const CoinDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchCoinDetailEvent extends CoinDetailEvent {
  final String coinId;
  final int days;

  const FetchCoinDetailEvent({required this.coinId, this.days = 7});

  @override
  List<Object?> get props => [coinId, days];
}

abstract class CoinDetailState extends Equatable {
  const CoinDetailState();

  @override
  List<Object?> get props => [];
}

class CoinDetailInitialState extends CoinDetailState {}

class CoinDetailLoadingState extends CoinDetailState {}

class CoinDetailLoadedState extends CoinDetailState {
  final CoinDetailEntity coinDetail;
  final List<ChartPointEntity> chartPoints;
  final int selectedDays;
  final bool isChartLoading;

  const CoinDetailLoadedState({
    required this.coinDetail,
    required this.chartPoints,
    required this.selectedDays,
    this.isChartLoading = false,
  });

  CoinDetailLoadedState copyWith({
    CoinDetailEntity? coinDetail,
    List<ChartPointEntity>? chartPoints,
    int? selectedDays,
    bool? isChartLoading,
  }) {
    return CoinDetailLoadedState(
      coinDetail: coinDetail ?? this.coinDetail,
      chartPoints: chartPoints ?? this.chartPoints,
      selectedDays: selectedDays ?? this.selectedDays,
      isChartLoading: isChartLoading ?? this.isChartLoading,
    );
  }

  @override
  List<Object?> get props => [coinDetail, chartPoints, selectedDays, isChartLoading];
}

class CoinDetailErrorState extends CoinDetailState {
  final String errorMessage;

  const CoinDetailErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class CoinDetailBloc extends Bloc<CoinDetailEvent, CoinDetailState> {
  final GetCoinDetailUseCase getCoinDetailUseCase;
  final GetCoinChartUseCase getCoinChartUseCase;

  CoinDetailBloc({
    required this.getCoinDetailUseCase,
    required this.getCoinChartUseCase,
  }) : super(CoinDetailInitialState()) {
    on<FetchCoinDetailEvent>(_onFetchCoinDetail);
  }

  Future<void> _onFetchCoinDetail(
    FetchCoinDetailEvent event,
    Emitter<CoinDetailState> emit,
  ) async {
    // If already loaded for the SAME coin, update ONLY the chart without reloading the whole page UI
    if (state is CoinDetailLoadedState) {
      final currentState = state as CoinDetailLoadedState;
      if (currentState.coinDetail.id.toLowerCase() == event.coinId.toLowerCase()) {
        emit(currentState.copyWith(
          isChartLoading: true,
          selectedDays: event.days,
        ));

        final chartResult = await getCoinChartUseCase(event.coinId, days: event.days);

        emit(currentState.copyWith(
          isChartLoading: false,
          chartPoints: chartResult.chartPoints ?? <ChartPointEntity>[],
          selectedDays: event.days,
        ));
        return;
      }
    }

    // First time load: emit full page loading state
    emit(CoinDetailLoadingState());

    final detailResult = await getCoinDetailUseCase(event.coinId);
    final chartResult = await getCoinChartUseCase(event.coinId, days: event.days);

    if (detailResult.failure != null) {
      emit(CoinDetailErrorState(errorMessage: detailResult.failure!.message));
    } else if (detailResult.coinDetail == null) {
      emit(const CoinDetailErrorState(errorMessage: 'Coin detail unavailable.'));
    } else {
      emit(CoinDetailLoadedState(
        coinDetail: detailResult.coinDetail!,
        chartPoints: chartResult.chartPoints ?? <ChartPointEntity>[],
        selectedDays: event.days,
        isChartLoading: false,
      ));
    }
  }
}
