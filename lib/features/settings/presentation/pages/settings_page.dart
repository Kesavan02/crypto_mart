import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/currencies.dart';
import '../state/settings_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesQuery(CurrencyEntity currency, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    final codeMatch = currency.code.toLowerCase().contains(q);
    final nameMatch = currency.name.toLowerCase().contains(q);
    final symbolMatch = currency.symbol.toLowerCase().contains(q);

    // Country and keyword alias mapping for intuitive searches
    const aliases = {
      'USD': ['usa', 'us', 'america', 'united states', 'dollar'],
      'EUR': ['europe', 'eurozone', 'euro', 'eu'],
      'GBP': ['uk', 'britain', 'england', 'united kingdom', 'pound'],
      'INR': ['india', 'indian', 'rupee', 'bharat'],
      'JPY': ['japan', 'japanese', 'yen'],
      'AUD': ['australia', 'australian', 'dollar'],
      'CAD': ['canada', 'canadian', 'dollar'],
      'BRL': ['brazil', 'brazilian', 'real'],
      'CNY': ['china', 'chinese', 'yuan', 'rmb'],
    };

    final aliasMatch = aliases[currency.code]?.any(
          (alias) => alias.contains(q) || q.contains(alias),
        ) ??
        false;

    return codeMatch || nameMatch || symbolMatch || aliasMatch;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final filteredCurrencies = CurrencyEntity.supportedCurrencies
            .where((c) => _matchesQuery(c, _searchQuery))
            .toList();

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Theme Appearance Section ─────────────────────────────
                  const Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.accentCyan : AppColors.primaryBlue)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: isDark ? AppColors.accentCyanBright : AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDark ? 'Dark Mode' : 'Light Mode',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isDark
                                      ? 'OLED pitch dark glassmorphic interface'
                                      : 'Clean high-contrast light interface',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textMutedDark : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch.adaptive(
                            value: isDark,
                            activeThumbColor: AppColors.accentCyanBright,
                            activeTrackColor: AppColors.accentCyan.withValues(alpha: 0.4),
                            onChanged: (val) {
                              context.read<SettingsCubit>().changeThemeMode(
                                    val ? ThemeMode.dark : ThemeMode.light,
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── 2. Display Currency Section ─────────────────────────────
                  const Text(
                    'Display Currency',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select your country currency to convert all prices, market caps, and charts automatically.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Professional Currency Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search country or currency (e.g., India, USD, Euro, Yen)',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textMutedDark : Colors.grey.shade500,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? AppColors.accentCyanBright : AppColors.primaryBlue,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                color: isDark ? AppColors.textMutedDark : Colors.grey.shade600,
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Responsive Currency Grid/List or Empty State
                  if (filteredCurrencies.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: isDark ? AppColors.textMutedDark : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No currency found for "$_searchQuery"',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try searching by country name (India, Japan, USA) or code (USD, INR, EUR).',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textMutedDark : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 580;

                        if (isWide) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredCurrencies.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 10,
                            ),
                            itemBuilder: (context, index) {
                              return _buildCurrencyTile(
                                context,
                                filteredCurrencies[index],
                                state.selectedCurrency.code,
                                isDark,
                              );
                            },
                          );
                        } else {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredCurrencies.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildCurrencyTile(
                                  context,
                                  filteredCurrencies[index],
                                  state.selectedCurrency.code,
                                  isDark,
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyTile(
    BuildContext context,
    CurrencyEntity currency,
    String selectedCode,
    bool isDark,
  ) {
    final isSelected = selectedCode == currency.code;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.accentCyan
              : (isDark ? AppColors.borderDark : Colors.grey.shade300),
          width: isSelected ? 1.8 : 1.0,
        ),
      ),
      child: ListTile(
        onTap: () {
          context.read<SettingsCubit>().changeCurrency(currency);
        },
        leading: Text(
          currency.flag,
          style: const TextStyle(fontSize: 24),
        ),
        title: Row(
          children: [
            Text(
              currency.code,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${currency.symbol})',
              style: const TextStyle(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        subtitle: Text(
          currency.name,
          style: const TextStyle(fontSize: 11.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle_rounded,
                color: AppColors.accentCyan,
                size: 20,
              )
            : null,
      ),
    );
  }
}
