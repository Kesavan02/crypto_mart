import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crypto_mart/features/settings/presentation/state/settings_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/entities/coin_entity.dart';
import '../state/coin_detail_bloc.dart';
import '../state/watchlist_cubit.dart';
import '../widgets/custom_rounded_app_bar.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/price_chart.dart';
import '../widgets/coin_icon.dart';

class CoinDetailPage extends StatelessWidget {
  final CoinEntity? coinEntity;
  final String? coinId;
  final bool? showAppBar;

  const CoinDetailPage({
    super.key,
    this.coinEntity,
    this.coinId,
    this.showAppBar,
  });

  @override
  Widget build(BuildContext context) {
    final targetId = coinId ?? coinEntity?.id ?? 'bitcoin';
    return BlocProvider<CoinDetailBloc>(
      key: ValueKey('coin_detail_$targetId'),
      create: (_) => sl<CoinDetailBloc>()
        ..add(FetchCoinDetailEvent(coinId: targetId)),
      child: _CoinDetailView(
        coinEntity: coinEntity,
        coinId: targetId,
        showAppBar: showAppBar,
      ),
    );
  }
}

class _CoinDetailView extends StatefulWidget {
  final CoinEntity? coinEntity;
  final String coinId;
  final bool? showAppBar;

  const _CoinDetailView({
    this.coinEntity,
    required this.coinId,
    this.showAppBar,
  });

  @override
  State<_CoinDetailView> createState() => _CoinDetailViewState();
}

class _CoinDetailViewState extends State<_CoinDetailView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final mutedTextColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    final shouldShowAppBar =
        widget.showAppBar ?? !ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: shouldShowAppBar
          ? CustomRoundedAppBar(
              title: widget.coinEntity?.name ?? 'Coin Details',
              showBrand: false,
              showLiveIndicator: false,
              actions: [
                BlocBuilder<WatchlistCubit, WatchlistState>(
                  builder: (context, state) {
                    final isStarred = state.isWatched(widget.coinId);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF161E2E)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2A364F)
                              : const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        tooltip: isStarred
                            ? 'Remove from Watchlist'
                            : 'Add to Watchlist',
                        icon: Icon(
                          isStarred
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: isStarred
                              ? const Color(0xFFFFD600)
                              : (isDark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight),
                          size: 18,
                        ),
                        onPressed: () {
                          context.read<WatchlistCubit>().toggleWatchlist(
                                widget.coinId,
                              );
                        },
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: BlocBuilder<CoinDetailBloc, CoinDetailState>(
        builder: (context, state) {
          if (state is CoinDetailLoadingState) {
            return const LoadingStateWidget(
              message: 'Loading price charts & data...',
            );
          }

          if (state is CoinDetailErrorState) {
            return ErrorStateWidget(
              errorMessage: state.errorMessage,
              onRetry: () {
                context.read<CoinDetailBloc>().add(
                      FetchCoinDetailEvent(coinId: widget.coinId),
                    );
              },
            );
          }

          if (state is CoinDetailLoadedState) {
            final detail = state.coinDetail;
            final isPositive = detail.priceChangePercentage24h >= 0;
            final changeColor =
                isPositive ? AppColors.gainGreen : AppColors.lossRed;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CoinIcon(
                        imageUrl: detail.imageUrl,
                        symbol: detail.symbol,
                        size: 48,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryTextColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              detail.symbol,
                              style: TextStyle(
                                color: mutedTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          final currency = settingsState.selectedCurrency;
                          final price =
                              detail.currentPrice * currency.rateFromUsd;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${currency.symbol}${price.toStringAsFixed(price < 1.0 ? 4 : 2)}',
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: changeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${isPositive ? '+' : ''}${detail.priceChangePercentage24h.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: changeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (!shouldShowAppBar) ...[
                        const SizedBox(width: 8),
                        BlocBuilder<WatchlistCubit, WatchlistState>(
                          builder: (context, state) {
                            final isStarred = state.isWatched(widget.coinId);
                            return IconButton(
                              icon: Icon(
                                isStarred
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: isStarred
                                    ? Colors.amber
                                    : secondaryTextColor,
                                size: 24,
                              ),
                              onPressed: () {
                                context.read<WatchlistCubit>().toggleWatchlist(
                                      widget.coinId,
                                    );
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  GlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Analytics Chart',
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        PriceChart(
                          points: state.chartPoints,
                          isPositive: isPositive,
                          selectedDays: state.selectedDays,
                          isChartLoading: state.isChartLoading,
                          onDaysSelected: (days) {
                            context.read<CoinDetailBloc>().add(
                                  FetchCoinDetailEvent(
                                    coinId: widget.coinId,
                                    days: days,
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Market Statistics',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, settingsState) {
                      final currency = settingsState.selectedCurrency;
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final crossAxisCount = width > 700 ? 3 : 2;
                          final aspectRatio = width > 700
                              ? 2.8
                              : (width > 450 ? 2.4 : 2.0);

                          return GridView.count(
                            crossAxisCount: crossAxisCount,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: aspectRatio,
                            children: [
                              _buildInfoTile(
                                context,
                                'Market Cap',
                                '${currency.symbol}${_formatBigNumber(detail.marketCap * currency.rateFromUsd)}',
                              ),
                              _buildInfoTile(
                                context,
                                '24h Volume',
                                '${currency.symbol}${_formatBigNumber(detail.totalVolume * currency.rateFromUsd)}',
                              ),
                              _buildInfoTile(
                                context,
                                '24h High',
                                '${currency.symbol}${(detail.high24h * currency.rateFromUsd).toStringAsFixed(2)}',
                              ),
                              _buildInfoTile(
                                context,
                                '24h Low',
                                '${currency.symbol}${(detail.low24h * currency.rateFromUsd).toStringAsFixed(2)}',
                              ),
                              _buildInfoTile(
                                context,
                                'Circulating Supply',
                                _formatBigNumber(detail.circulatingSupply),
                              ),
                              _buildInfoTile(
                                context,
                                'All-Time High (ATH)',
                                '${currency.symbol}${(detail.ath * currency.rateFromUsd).toStringAsFixed(2)}',
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  if (detail.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'About',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassmorphicCard(
                      child: Text(
                        detail.description,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final valueColor = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(color: titleColor, fontSize: 12),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBigNumber(double number) {
    if (number >= 1e12) return '${(number / 1e12).toStringAsFixed(2)}T';
    if (number >= 1e9) return '${(number / 1e9).toStringAsFixed(2)}B';
    if (number >= 1e6) return '${(number / 1e6).toStringAsFixed(2)}M';
    if (number >= 1e3) return '${(number / 1e3).toStringAsFixed(2)}K';
    return number.toStringAsFixed(2);
  }
}
