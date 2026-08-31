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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchFilterBar(
          onSearchChanged: (query) {
            context.read<CryptoListBloc>().add(FetchCryptoListEvent(search: query));
          },
          onSortChanged: (sortBy) {
            context.read<CryptoListBloc>().add(FetchCryptoListEvent(sortBy: sortBy));
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
                    context.read<CryptoListBloc>().add(const FetchCryptoListEvent());
                  },
                );
              }

              if (state is CryptoListEmptyState) {
                return EmptyStateWidget(
                  title: 'No Assets Found',
                  message: state.message,
                );
              }

              if (state is CryptoListLoadedState) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<CryptoListBloc>().add(const FetchCryptoListEvent());
                  },
                  child: ListView.builder(
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
