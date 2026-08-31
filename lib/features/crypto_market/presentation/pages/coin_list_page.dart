import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/coin_entity.dart';
import '../state/crypto_list_bloc.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/search_filter_bar.dart';

class CoinListPage extends StatelessWidget {
  final Function(CoinEntity)? onCoinSelected;

  const CoinListPage({super.key, this.onCoinSelected});

  Future<void> _handleRefresh(
    BuildContext context, {
    bool resetFilters = true,
  }) async {
    final completer = Completer<void>();
    context.read<CryptoListBloc>().add(
      RefreshCryptoListEvent(completer: completer, resetFilters: resetFilters),
    );
    try {
      await completer.future.timeout(const Duration(seconds: 15));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<CryptoListBloc, CryptoListState>(
          buildWhen: (previous, current) {
            return current is CryptoListLoadedState ||
                current is CryptoListEmptyState ||
                current is CryptoListInitialState;
          },
          builder: (context, state) {
            final bloc = context.read<CryptoListBloc>();
            return SearchFilterBar(
              key: ValueKey('${bloc.currentSearch}_${bloc.currentSortBy}'),
              initialSearch: bloc.currentSearch,
              initialSort: bloc.currentSortBy,
              onSearchChanged: (query) {
                context.read<CryptoListBloc>().add(
                  FetchCryptoListEvent(search: query),
                );
              },
              onSortChanged: (sortBy) {
                context.read<CryptoListBloc>().add(
                  FetchCryptoListEvent(sortBy: sortBy),
                );
              },
            );
          },
        ),
        Expanded(
          child: BlocBuilder<CryptoListBloc, CryptoListState>(
            builder: (context, state) {
              if (state is CryptoListLoadingState) {
                return const LoadingStateWidget();
              }

              if (state is CryptoListErrorState) {
                return ErrorStateWidget(
                  errorMessage: state.errorMessage,
                  onRetry: () {
                    context.read<CryptoListBloc>().add(
                      const RefreshCryptoListEvent(),
                    );
                  },
                );
              }

              if (state is CryptoListEmptyState) {
                return RefreshIndicator(
                  onRefresh: () => _handleRefresh(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: EmptyStateWidget(
                          title: 'No Assets Found',
                          message: state.message,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is CryptoListLoadedState) {
                return RefreshIndicator(
                  onRefresh: () => _handleRefresh(context),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.coins.length,
                    itemBuilder: (context, index) {
                      final coin = state.coins[index];
                      return CoinListItem(
                        coin: coin,
                        onTap: () {
                          if (onCoinSelected != null) {
                            onCoinSelected!(coin);
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/coin_detail',
                              arguments: coin,
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
