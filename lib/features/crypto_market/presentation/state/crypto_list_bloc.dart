import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/coin_entity.dart';
import '../../domain/usecases/get_coins_usecase.dart';

abstract class CryptoListEvent extends Equatable {
  const CryptoListEvent();

  @override
  List<Object?> get props => [];
}

class FetchCryptoListEvent extends CryptoListEvent {
  final String? search;
  final String? sortBy;
  final String? order;
  final bool resetFilters;

  const FetchCryptoListEvent({
    this.search,
    this.sortBy,
    this.order,
    this.resetFilters = false,
  });

  @override
  List<Object?> get props => [search, sortBy, order, resetFilters];
}

class RefreshCryptoListEvent extends CryptoListEvent {
  final Completer<void>? completer;
  final bool resetFilters;

  const RefreshCryptoListEvent({
    this.completer,
    this.resetFilters = false,
  });

  @override
  List<Object?> get props => [completer, resetFilters];
}

abstract class CryptoListState extends Equatable {
  const CryptoListState();

  @override
  List<Object?> get props => [];
}

class CryptoListInitialState extends CryptoListState {}

class CryptoListLoadingState extends CryptoListState {}

class CryptoListLoadedState extends CryptoListState {
  final List<CoinEntity> coins;
  final String? currentSearch;
  final String? currentSortBy;
  final String? currentOrder;

  const CryptoListLoadedState({
    required this.coins,
    this.currentSearch,
    this.currentSortBy,
    this.currentOrder,
  });

  @override
  List<Object?> get props => [coins, currentSearch, currentSortBy, currentOrder];
}

class CryptoListEmptyState extends CryptoListState {
  final String message;

  const CryptoListEmptyState({required this.message});

  @override
  List<Object?> get props => [message];
}

class CryptoListErrorState extends CryptoListState {
  final String errorMessage;

  const CryptoListErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class CryptoListBloc extends Bloc<CryptoListEvent, CryptoListState> {
  final GetCoinsUseCase getCoinsUseCase;

  String? _currentSearch;
  String? _currentSortBy;
  String? _currentOrder;

  String? get currentSearch => _currentSearch;
  String? get currentSortBy => _currentSortBy;
  String? get currentOrder => _currentOrder;

  CryptoListBloc({required this.getCoinsUseCase})
      : super(CryptoListInitialState()) {
    on<FetchCryptoListEvent>(_onFetchCoins);
    on<RefreshCryptoListEvent>(_onRefreshCoins);
  }

  Future<void> _onFetchCoins(
    FetchCryptoListEvent event,
    Emitter<CryptoListState> emit,
  ) async {
    if (event.resetFilters) {
      _currentSearch = null;
      _currentSortBy = null;
      _currentOrder = null;
    } else {
      if (event.search != null) {
        _currentSearch = event.search;
      }
      if (event.sortBy != null) {
        _currentSortBy = event.sortBy;
      }
      if (event.order != null) {
        _currentOrder = event.order;
      }
    }

    emit(CryptoListLoadingState());
    await _performFetch(emit);
  }

  Future<void> _onRefreshCoins(
    RefreshCryptoListEvent event,
    Emitter<CryptoListState> emit,
  ) async {
    try {
      if (event.resetFilters) {
        _currentSearch = null;
        _currentSortBy = null;
        _currentOrder = null;
      }
      await _performFetch(emit);
    } finally {
      if (event.completer != null && !event.completer!.isCompleted) {
        event.completer!.complete();
      }
    }
  }

  Future<void> _performFetch(Emitter<CryptoListState> emit) async {
    final effectiveSearch = (_currentSearch != null && _currentSearch!.trim().isNotEmpty)
        ? _currentSearch!.trim()
        : null;

    final result = await getCoinsUseCase(
      search: effectiveSearch,
      sortBy: _currentSortBy,
      order: _currentOrder,
    );

    if (result.failure != null) {
      emit(CryptoListErrorState(
        errorMessage: result.failure!.message,
      ));
    } else if (result.coins == null || result.coins!.isEmpty) {
      emit(const CryptoListEmptyState(
        message: 'No cryptocurrency assets found matching your search criteria.',
      ));
    } else {
      emit(CryptoListLoadedState(
        coins: result.coins!,
        currentSearch: _currentSearch,
        currentSortBy: _currentSortBy,
        currentOrder: _currentOrder,
      ));
    }
  }
}
