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
  final bool isSilent;

  const FetchCryptoListEvent({
    this.search,
    this.sortBy,
    this.order,
    this.isSilent = false,
  });

  @override
  List<Object?> get props => [search, sortBy, order, isSilent];
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
  final String currentSearch;
  final String currentSortBy;
  final bool isRefreshing;

  const CryptoListLoadedState({
    required this.coins,
    this.currentSearch = '',
    this.currentSortBy = 'market_cap',
    this.isRefreshing = false,
  });

  CryptoListLoadedState copyWith({
    List<CoinEntity>? coins,
    String? currentSearch,
    String? currentSortBy,
    bool? isRefreshing,
  }) {
    return CryptoListLoadedState(
      coins: coins ?? this.coins,
      currentSearch: currentSearch ?? this.currentSearch,
      currentSortBy: currentSortBy ?? this.currentSortBy,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props =>
      [coins, currentSearch, currentSortBy, isRefreshing];
}

class CryptoListEmptyState extends CryptoListState {
  final String message;
  final String currentSearch;
  final String currentSortBy;

  const CryptoListEmptyState({
    required this.message,
    this.currentSearch = '',
    this.currentSortBy = 'market_cap',
  });

  @override
  List<Object?> get props => [message, currentSearch, currentSortBy];
}

class CryptoListErrorState extends CryptoListState {
  final String errorMessage;

  const CryptoListErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class CryptoListBloc extends Bloc<CryptoListEvent, CryptoListState> {
  final GetCoinsUseCase getCoinsUseCase;

  String _searchQuery = '';
  String _sortBy = 'market_cap';

  CryptoListBloc({required this.getCoinsUseCase})
      : super(CryptoListInitialState()) {
    on<FetchCryptoListEvent>(_onFetchCoins);
  }

  Future<void> _onFetchCoins(
    FetchCryptoListEvent event,
    Emitter<CryptoListState> emit,
  ) async {
    if (event.search != null) _searchQuery = event.search!;
    if (event.sortBy != null) _sortBy = event.sortBy!;

    if (!event.isSilent && state is! CryptoListLoadedState) {
      emit(CryptoListLoadingState());
    } else if (state is CryptoListLoadedState) {
      final currentLoaded = state as CryptoListLoadedState;
      emit(currentLoaded.copyWith(
        isRefreshing: true,
        currentSearch: _searchQuery,
        currentSortBy: _sortBy,
      ));
    }

    final result = await getCoinsUseCase(
      search: _searchQuery,
      sortBy: _sortBy,
      order: event.order,
    );

    result.fold(
      onSuccess: (coins) {
        if (coins.isEmpty) {
          emit(CryptoListEmptyState(
            message:
                'No cryptocurrency assets found matching your search criteria.',
            currentSearch: _searchQuery,
            currentSortBy: _sortBy,
          ));
        } else {
          emit(CryptoListLoadedState(
            coins: coins,
            currentSearch: _searchQuery,
            currentSortBy: _sortBy,
            isRefreshing: false,
          ));
        }
      },
      onFailure: (failure) {
        if (state is CryptoListLoadedState) {
          final currentLoaded = state as CryptoListLoadedState;
          emit(currentLoaded.copyWith(isRefreshing: false));
        } else {
          emit(CryptoListErrorState(errorMessage: failure.message));
        }
      },
    );
  }
}
