import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crypto_mart/features/settings/presentation/state/settings_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/coin_entity.dart';
import '../state/watchlist_cubit.dart';

class CoinListItem extends StatelessWidget {
  final CoinEntity coin;
  final VoidCallback onTap;

  const CoinListItem({
    super.key,
    required this.coin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPositive = coin.priceChangePercentage24h >= 0;
    final changeColor = isPositive ? AppColors.gainGreen : AppColors.lossRed;

    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '${coin.marketCapRank}',
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ClipOval(
                child: Image.network(
                  coin.imageUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 36,
                    height: 36,
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    child: Center(
                      child: Text(
                        coin.symbol.substring(0, 1),
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text.rich(
            TextSpan(
              text: coin.name,
              style: TextStyle(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: '  ${coin.symbol}',
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final currency = settingsState.selectedCurrency;
              final mcap = coin.marketCap * currency.rateFromUsd;
              return Text(
                'MCap: ${currency.symbol}${_formatNumber(mcap)}',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              );
            },
          ),
          trailing: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settingsState) {
                    final currency = settingsState.selectedCurrency;
                    final price = coin.currentPrice * currency.rateFromUsd;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${currency.symbol}${price.toStringAsFixed(price < 1.0 ? 4 : 2)}',
                          style: TextStyle(
                            color: primaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: changeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.arrow_drop_up_rounded
                                    : Icons.arrow_drop_down_rounded,
                                color: changeColor,
                                size: 16,
                              ),
                              Text(
                                '${coin.priceChangePercentage24h.abs().toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: changeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 4),
                BlocBuilder<WatchlistCubit, WatchlistState>(
                  builder: (context, state) {
                    final isStarred = state.isWatched(coin.id);
                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isStarred ? Colors.amber : mutedTextColor,
                        size: 22,
                      ),
                      onPressed: () {
                        context
                            .read<WatchlistCubit>()
                            .toggleWatchlist(coin.id);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1e12) return '${(number / 1e12).toStringAsFixed(2)}T';
    if (number >= 1e9) return '${(number / 1e9).toStringAsFixed(2)}B';
    if (number >= 1e6) return '${(number / 1e6).toStringAsFixed(2)}M';
    if (number >= 1e3) return '${(number / 1e3).toStringAsFixed(2)}K';
    return number.toStringAsFixed(2);
  }
}
