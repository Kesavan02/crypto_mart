import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/coin_entity.dart';
import '../state/watchlist_cubit.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_state_widget.dart';

class WatchlistPage extends StatelessWidget {
  final Function(CoinEntity)? onCoinSelected;

  const WatchlistPage({super.key, this.onCoinSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (context, state) {
        if (state.isLoading && state.watchedCoins.isEmpty) {
          return const LoadingStateWidget(
            message: 'Loading your bookmarked cryptocurrencies...',
          );
        }

        if (state.errorMessage != null && state.watchedCoins.isEmpty) {
          return ErrorStateWidget(
            errorMessage: state.errorMessage!,
            onRetry: () {
              context.read<WatchlistCubit>().loadWatchlist();
            },
          );
        }

        if (state.watchlistIds.isEmpty || state.watchedCoins.isEmpty) {
          return EmptyStateWidget(
            title: 'Your Watchlist is Empty',
            message:
                'Tap the star icon on any cryptocurrency asset to bookmark it for quick access.',
            icon: Icons.star_outline_rounded,
            onAction: () {
              context.read<WatchlistCubit>().loadWatchlist();
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<WatchlistCubit>().loadWatchlist();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 12),
            itemCount: state.watchedCoins.length,
            itemBuilder: (context, index) {
              final coin = state.watchedCoins[index];
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
      },
    );
  }
}
