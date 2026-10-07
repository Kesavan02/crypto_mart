import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../settings/presentation/state/settings_cubit.dart';
import '../state/market_stats_bloc.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/market_stat_card.dart';

class MarketStatsPage extends StatelessWidget {
  const MarketStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MarketStatsBloc>(
      create: (_) => sl<MarketStatsBloc>()..add(const FetchMarketStatsEvent()),
      child: const _MarketStatsView(),
    );
  }
}

class _MarketStatsView extends StatelessWidget {
  const _MarketStatsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = theme.colorScheme.onSurface;

    return BlocBuilder<MarketStatsBloc, MarketStatsState>(
      builder: (context, state) {
        if (state is MarketStatsLoadingState) {
          return const LoadingStateWidget(
            message: 'Loading global market metrics...',
          );
        }

        if (state is MarketStatsErrorState) {
          return ErrorStateWidget(
            errorMessage: state.message,
            onRetry: () {
              context
                  .read<MarketStatsBloc>()
                  .add(const FetchMarketStatsEvent());
            },
          );
        }

        if (state is MarketStatsLoadedState) {
          final stats = state.stats;
          final isPositive = stats.marketCapChangePercentage24h >= 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settingsState) {
                    final currency = settingsState.selectedCurrency;
                    final totalMcap =
                        stats.totalMarketCapUsd * currency.rateFromUsd;
                    final totalVol =
                        stats.totalVolume24hUsd * currency.rateFromUsd;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      AppColors.primaryBlue,
                                      AppColors.surfaceDark
                                    ]
                                  : [
                                      AppColors.primaryBlue,
                                      AppColors.primaryBlue
                                          .withValues(alpha: 0.85)
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Global Crypto Market Cap',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${currency.symbol}${_formatBigNumber(totalMcap)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    isPositive
                                        ? Icons.trending_up_rounded
                                        : Icons.trending_down_rounded,
                                    color: isPositive
                                        ? AppColors.gainGreen
                                        : AppColors.lossRed,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${isPositive ? '+' : ''}${stats.marketCapChangePercentage24h.toStringAsFixed(2)}% in 24h',
                                    style: TextStyle(
                                      color: isPositive
                                          ? AppColors.gainGreen
                                          : AppColors.lossRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Market Highlights & Metrics',
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount = width > 700 ? 3 : 2;
                            final aspectRatio = width > 700
                                ? 2.5
                                : (width > 450 ? 2.0 : 1.6);

                            return GridView.count(
                              crossAxisCount: crossAxisCount,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: aspectRatio,
                              children: [
                                MarketStatCard(
                                  title: '24h Total Volume',
                                  value:
                                      '${currency.symbol}${_formatBigNumber(totalVol)}',
                                  icon: Icons.bar_chart_rounded,
                                  accentColor: isDark
                                      ? AppColors.accentCyanBright
                                      : AppColors.primaryBlue,
                                ),
                                MarketStatCard(
                                  title: 'Bitcoin Dominance',
                                  value:
                                      '${stats.btcDominance.toStringAsFixed(1)}%',
                                  icon: Icons.currency_bitcoin_rounded,
                                  accentColor: Colors.amber,
                                ),
                                MarketStatCard(
                                  title: 'Ethereum Dominance',
                                  value:
                                      '${stats.ethDominance.toStringAsFixed(1)}%',
                                  icon: Icons.auto_awesome_rounded,
                                  accentColor: Colors.purpleAccent,
                                ),
                                MarketStatCard(
                                  title: 'Active Cryptos',
                                  value: _formatInteger(
                                      stats.activeCryptocurrencies),
                                  icon: Icons.hub_rounded,
                                  accentColor: AppColors.gainGreen,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  String _formatBigNumber(double number) {
    if (number >= 1e12) {
      return '${(number / 1e12).toStringAsFixed(2)} Trillion';
    }
    if (number >= 1e9) return '${(number / 1e9).toStringAsFixed(2)} Billion';
    if (number >= 1e6) return '${(number / 1e6).toStringAsFixed(2)} Million';
    return number.toStringAsFixed(2);
  }

  String _formatInteger(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
