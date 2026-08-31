import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/coin_entity.dart';
import '../state/coin_detail_bloc.dart';
import '../state/crypto_list_bloc.dart';
import '../state/watchlist_cubit.dart';
import '../widgets/custom_3d_drawer.dart';
import '../widgets/empty_state_widget.dart';
import 'coin_detail_page.dart';
import 'coin_list_page.dart';
import 'market_stats_page.dart';
import 'watchlist_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  CoinEntity? _selectedDesktopCoin;
  double _leftPanelWidth = 380.0;

  final List<String> _titles = const [
    'Crypto Market',
    'Watchlist',
    'Market Overview',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    context.read<CryptoListBloc>().add(const FetchCryptoListEvent());
    context.read<WatchlistCubit>().loadWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    Widget content;
    if (isDesktop) {
      content = _buildDesktopContent();
    } else {
      content = _buildMobileTabletContent();
    }

    return Custom3DAnimatedDrawer(
      selectedIndex: _currentIndex,
      title: _titles[_currentIndex],
      onIndexSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      child: content,
    );
  }

  Widget _buildMobileTabletContent() {
    final pages = [
      CoinListPage(
        onCoinSelected: (coin) {
          Navigator.pushNamed(context, '/coin_detail', arguments: coin);
        },
      ),
      WatchlistPage(
        onCoinSelected: (coin) {
          Navigator.pushNamed(context, '/coin_detail', arguments: coin);
        },
      ),
      const MarketStatsPage(),
      const SettingsPage(),
    ];

    return pages[_currentIndex];
  }

  Widget _buildDesktopContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showSplitView = _currentIndex == 0 || _currentIndex == 1;
        final availableWidth = constraints.maxWidth;

        final minLeftWidth = 380.0;
        final maxLeftWidth = (availableWidth - 400.0).clamp(
          minLeftWidth,
          availableWidth,
        );
        final currentLeftWidth = showSplitView
            ? _leftPanelWidth.clamp(minLeftWidth, maxLeftWidth)
            : availableWidth;

        return Row(
          children: [
            // Left Panel (Coin List / Watchlist)
            if (showSplitView)
              SizedBox(
                width: currentLeftWidth,
                child: _currentIndex == 0
                    ? CoinListPage(
                        onCoinSelected: (coin) {
                          setState(() {
                            _selectedDesktopCoin = coin;
                          });
                          context.read<CoinDetailBloc>().add(
                            FetchCoinDetailEvent(coinId: coin.id),
                          );
                        },
                      )
                    : WatchlistPage(
                        onCoinSelected: (coin) {
                          setState(() {
                            _selectedDesktopCoin = coin;
                          });
                          context.read<CoinDetailBloc>().add(
                            FetchCoinDetailEvent(coinId: coin.id),
                          );
                        },
                      ),
              )
            else
              Expanded(
                child: _currentIndex == 2
                    ? const MarketStatsPage()
                    : const SettingsPage(),
              ),

            // Interactive Draggable Middle Divider Handle
            if (showSplitView) ...[
              MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _leftPanelWidth = (_leftPanelWidth + details.delta.dx)
                          .clamp(minLeftWidth, maxLeftWidth);
                    });
                  },
                  child: Container(
                    width: 12,
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        width: 2,
                        height: double.infinity,
                        color: isDark
                            ? AppColors.accentCyanBright.withValues(alpha: 0.6)
                            : AppColors.primaryBlue.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildRightDetailPanel(context, isDark)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRightDetailPanel(BuildContext context, bool isDark) {
    if (_currentIndex == 1) {
      return BlocBuilder<WatchlistCubit, WatchlistState>(
        builder: (context, watchlistState) {
          if (watchlistState.watchlistIds.isEmpty) {
            return const Center(
              child: EmptyStateWidget(
                title: 'No Watchlist Item Selected',
                message:
                    'Tap the star icon on any cryptocurrency asset to bookmark it for quick access.',
                icon: Icons.star_border_rounded,
              ),
            );
          }

          return BlocBuilder<CryptoListBloc, CryptoListState>(
            builder: (context, cryptoState) {
              if (cryptoState is CryptoListLoadedState) {
                final watchedCoins = cryptoState.coins
                    .where((c) => watchlistState.isWatched(c.id))
                    .toList();

                if (watchedCoins.isEmpty) {
                  return const Center(
                    child: EmptyStateWidget(
                      title: 'No Watchlist Item Selected',
                      message:
                          'Tap the star icon on any cryptocurrency asset to bookmark it for quick access.',
                      icon: Icons.star_border_rounded,
                    ),
                  );
                }

                final matchingCoins = watchedCoins.where(
                  (c) => c.id == _selectedDesktopCoin?.id,
                );
                final CoinEntity selectedCoin = matchingCoins.isNotEmpty
                    ? matchingCoins.first
                    : watchedCoins.first;

                return CoinDetailPage(
                  key: ValueKey(selectedCoin.id),
                  coinEntity: selectedCoin,
                  coinId: selectedCoin.id,
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

    final selectedCoin = _selectedDesktopCoin;
    return CoinDetailPage(
      key: ValueKey(selectedCoin?.id ?? 'bitcoin'),
      coinEntity: selectedCoin,
      coinId: selectedCoin?.id ?? 'bitcoin',
    );
  }
}
