import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crypto_mart/features/settings/presentation/state/settings_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/entities/coin_entity.dart';
import '../state/coin_detail_bloc.dart';
import '../state/watchlist_cubit.dart';
import '../widgets/custom_rounded_app_bar.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/price_chart.dart';

class CoinDetailPage extends StatefulWidget {
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
  State<CoinDetailPage> createState() => _CoinDetailPageState();
}

class _CoinDetailPageState extends State<CoinDetailPage> {
  late String _targetId;

  @override
  void initState() {
    super.initState();
    _targetId = widget.coinId ?? widget.coinEntity?.id ?? 'bitcoin';
    context.read<CoinDetailBloc>().add(FetchCoinDetailEvent(coinId: _targetId));
  }

  @override
  void didUpdateWidget(CoinDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTargetId = widget.coinId ?? widget.coinEntity?.id ?? 'bitcoin';
    if (newTargetId != _targetId) {
      _targetId = newTargetId;
      context.read<CoinDetailBloc>().add(
        FetchCoinDetailEvent(coinId: _targetId),
      );
    }
  }

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
              actions: [
                BlocBuilder<WatchlistCubit, WatchlistState>(
                  builder: (context, state) {
                    final isStarred = state.isWatched(_targetId);
                    return IconButton(
                      icon: Icon(
                        isStarred
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isStarred ? Colors.amber : Colors.white,
                      ),
                      onPressed: () {
                        context.read<WatchlistCubit>().toggleWatchlist(
                          _targetId,
                        );
                      },
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
                  FetchCoinDetailEvent(coinId: _targetId),
                );
              },
            );
          }

          if (state is CoinDetailLoadedState) {
            final detail = state.coinDetail;
            final isPositive = detail.priceChangePercentage24h >= 0;
            final changeColor = isPositive
                ? AppColors.gainGreen
                : AppColors.lossRed;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          detail.imageUrl,
                          width: 48,
                          height: 48,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.monetization_on_rounded,
                            size: 48,
                            color: isDark
                                ? AppColors.accentCyanBright
                                : AppColors.primaryBlue,
                          ),
                        ),
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
                            final isStarred = state.isWatched(_targetId);
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
                                  _targetId,
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
                    padding: const EdgeInsets.fromLTRB(10, 16, 12, 14),
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
                                coinId: _targetId,
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
                  const SizedBox(height: 36),
                ],
              ),
            ),
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
