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

  const FetchCryptoListEvent({this.search, this.sortBy, this.order});

  @override
  List<Object?> get props => [search, sortBy, order];
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

  const CryptoListLoadedState({
    required this.coins,
    this.currentSearch,
    this.currentSortBy,
  });

  @override
  List<Object?> get props => [coins, currentSearch, currentSortBy];
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

  CryptoListBloc({required this.getCoinsUseCase})
      : super(CryptoListInitialState()) {
    on<FetchCryptoListEvent>(_onFetchCoins);
  }

  Future<void> _onFetchCoins(
    FetchCryptoListEvent event,
    Emitter<CryptoListState> emit,
  ) async {
    emit(CryptoListLoadingState());

    final result = await getCoinsUseCase(
      search: event.search,
      sortBy: event.sortBy,
      order: event.order,
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
        currentSearch: event.search,
        currentSortBy: event.sortBy,
      ));
    }
  }
}
