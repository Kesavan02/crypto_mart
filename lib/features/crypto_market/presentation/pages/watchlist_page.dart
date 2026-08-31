import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/coin_entity.dart';
import '../state/crypto_list_bloc.dart';
import '../state/watchlist_cubit.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/empty_state_widget.dart';

class WatchlistPage extends StatelessWidget {
  final Function(CoinEntity)? onCoinSelected;

  const WatchlistPage({super.key, this.onCoinSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (context, watchlistState) {
        if (watchlistState.watchlistIds.isEmpty) {
          return const EmptyStateWidget(
            title: 'Your Watchlist is Empty',
            message:
                'Tap the star icon on any cryptocurrency asset to bookmark it for quick access.',
            icon: Icons.star_outline_rounded,
          );
        }

        return BlocBuilder<CryptoListBloc, CryptoListState>(
          builder: (context, cryptoState) {
            if (cryptoState is CryptoListLoadedState) {
              final watchedCoins = cryptoState.coins
                  .where((c) => watchlistState.isWatched(c.id))
                  .toList();

              if (watchedCoins.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No Watched Coins in Current Feed',
                  message:
                      'Your bookmarked assets will appear here once loaded.',
                  icon: Icons.star_border_purple500_rounded,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 12),
                itemCount: watchedCoins.length,
                itemBuilder: (context, index) {
                  final coin = watchedCoins[index];
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
              );
            }

            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentCyan),
            );
          },
        );
      },
    );
  }
}
