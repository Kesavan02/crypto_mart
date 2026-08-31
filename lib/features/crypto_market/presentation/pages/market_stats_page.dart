import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crypto_mart/features/settings/presentation/state/settings_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/crypto_remote_data_source.dart';
import '../../data/models/market_stats_model.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/market_stat_card.dart';

class MarketStatsPage extends StatefulWidget {
  const MarketStatsPage({super.key});

  @override
  State<MarketStatsPage> createState() => _MarketStatsPageState();
}

class _MarketStatsPageState extends State<MarketStatsPage> {
  late final CryptoRemoteDataSource _dataSource;
  Future<MarketStatsModel>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _dataSource = CryptoRemoteDataSourceImpl(client: DioClient().instance);
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = _dataSource.getMarketStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = theme.colorScheme.onSurface;

    return FutureBuilder<MarketStatsModel>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingStateWidget(message: 'Loading global market metrics...');
        }

        if (snapshot.hasError) {
          return ErrorStateWidget(
            errorMessage: snapshot.error.toString(),
            onRetry: _loadStats,
          );
        }

        if (snapshot.hasData) {
          final stats = snapshot.data!;
          final isPositive = stats.marketCapChangePercentage24h >= 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settingsState) {
                    final currency = settingsState.selectedCurrency;
                    final totalMcap = stats.totalMarketCapUsd * currency.rateFromUsd;
                    final totalVol = stats.totalVolume24hUsd * currency.rateFromUsd;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [AppColors.primaryBlue, AppColors.surfaceDark]
                                  : [AppColors.primaryBlue, AppColors.primaryBlue.withValues(alpha: 0.85)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.3),
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
                                    color: isPositive ? AppColors.gainGreen : AppColors.lossRed,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${isPositive ? '+' : ''}${stats.marketCapChangePercentage24h.toStringAsFixed(2)}% in 24h',
                                    style: TextStyle(
                                      color: isPositive ? AppColors.gainGreen : AppColors.lossRed,
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
                                  value: '${currency.symbol}${_formatBigNumber(totalVol)}',
                                  icon: Icons.bar_chart_rounded,
                                  accentColor: isDark ? AppColors.accentCyanBright : AppColors.primaryBlue,
                                ),
                                const MarketStatCard(
                                  title: 'Bitcoin Dominance',
                                  value: '54.4%',
                                  icon: Icons.currency_bitcoin_rounded,
                                  accentColor: Colors.amber,
                                ),
                                const MarketStatCard(
                                  title: 'Ethereum Dominance',
                                  value: '12.1%',
                                  icon: Icons.auto_awesome_rounded,
                                  accentColor: Colors.purpleAccent,
                                ),
                                const MarketStatCard(
                                  title: 'Active Cryptos',
                                  value: '14,820',
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
    if (number >= 1e12) return '${(number / 1e12).toStringAsFixed(2)} Trillion';
    if (number >= 1e9) return '${(number / 1e9).toStringAsFixed(2)} Billion';
    if (number >= 1e6) return '${(number / 1e6).toStringAsFixed(2)} Million';
    return number.toStringAsFixed(2);
  }
}
