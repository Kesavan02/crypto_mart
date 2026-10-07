import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/currencies.dart';
import '../../../settings/presentation/state/settings_cubit.dart';
import '../state/crypto_list_bloc.dart';

class CustomRoundedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double height;
  final bool showBrand;
  final bool showLiveIndicator;
  final bool showCurrencyPicker;
  final bool showRefreshButton;
  final VoidCallback? onRefresh;

  const CustomRoundedAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.height = 62.0,
    this.showBrand = true,
    this.showLiveIndicator = true,
    this.showCurrencyPicker = true,
    this.showRefreshButton = true,
    this.onRefresh,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 680;

    final headerBg = isDark
        ? const Color(0xFF0F1420)
        : Colors.white;

    final bottomBorderColor = isDark
        ? const Color(0xFF1E2838)
        : const Color(0xFFE2E8F0);

    final titleTextColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);

    return Container(
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          bottom: BorderSide(
            color: bottomBorderColor,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // ── 1. Leading Button (Drawer / Back) ──────────────────────────
              if (leading != null)
                leading!
              else if (Navigator.canPop(context))
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: titleTextColor,
                    size: 18,
                  ),
                  onPressed: () => Navigator.maybePop(context),
                  tooltip: 'Back',
                ),

              const SizedBox(width: 4),

              // ── 2. Brand & Title Header ────────────────────────────────────
              Expanded(
                child: titleWidget ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showBrand) ...[
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF27354E)
                                    : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.asset(
                                'assets/images/crypto_mart_logo.png',
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.currency_bitcoin_rounded,
                                  color: isDark
                                      ? AppColors.accentCyanBright
                                      : AppColors.primaryBlue,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],

                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: titleTextColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Sleek minimal Live Feed Indicator
                        if (showLiveIndicator && !isCompact) ...[
                          const SizedBox(width: 10),
                          const _LiveMarketBadge(),
                        ],
                      ],
                    ),
              ),

              const SizedBox(width: 8),

              // ── 3. Actions: Enhanced Currency Dropdown & Refresh ───────────
              ...?actions,

              // Enhanced Currency Dropdown Menu
              if (showCurrencyPicker)
                const _EnhancedCurrencyDropdown(),

              // Quick Refresh Sync Button
              if (showRefreshButton)
                _RefreshButton(onRefresh: onRefresh),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── Sleek Minimal "LIVE" Market Pulse Badge ──────────────────────────────────
class _LiveMarketBadge extends StatefulWidget {
  const _LiveMarketBadge();

  @override
  State<_LiveMarketBadge> createState() => _LiveMarketBadgeState();
}

class _LiveMarketBadgeState extends State<_LiveMarketBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF00E676).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E676).withValues(alpha: _pulseAnimation.value),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E676).withValues(alpha: _pulseAnimation.value * 0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Color(0xFF00E676),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Enhanced Premium Currency Dropdown Menu ──────────────────────────────────
class _EnhancedCurrencyDropdown extends StatelessWidget {
  const _EnhancedCurrencyDropdown();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final current = state.selectedCurrency;

        return Theme(
          data: theme.copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: isDark ? const Color(0xFF131A29) : Colors.white,
              elevation: 16,
              shadowColor: Colors.black.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF28364F) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
          ),
          child: PopupMenuButton<CurrencyEntity>(
            tooltip: 'Select Display Currency',
            initialValue: current,
            onSelected: (currency) {
              context.read<SettingsCubit>().changeCurrency(currency);
            },
            offset: const Offset(0, 48),
            constraints: const BoxConstraints(minWidth: 280, maxWidth: 300),
            itemBuilder: (context) {
              return [
                // Header item (non-selectable)
                PopupMenuItem<CurrencyEntity>(
                  enabled: false,
                  height: 38,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DISPLAY CURRENCY',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E283C)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${CurrencyEntity.supportedCurrencies.length} FIAT',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const PopupMenuDivider(height: 1),

                // Currency List Items
                ...CurrencyEntity.supportedCurrencies.map((currency) {
                  final isSelected = currency.code == current.code;

                  return PopupMenuItem<CurrencyEntity>(
                    value: currency,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? const Color(0xFF1E2B45)
                                : const Color(0xFFEFF6FF))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(
                                color: isDark
                                    ? AppColors.accentCyanBright.withValues(alpha: 0.5)
                                    : AppColors.primaryBlue.withValues(alpha: 0.4),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Flag Avatar
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF192336)
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              currency.flag,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Currency Code & Full Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      currency.code,
                                      style: TextStyle(
                                        color: isSelected
                                            ? (isDark
                                                ? AppColors.accentCyanBright
                                                : AppColors.primaryBlue)
                                            : (isDark
                                                ? Colors.white
                                                : AppColors.textPrimaryLight),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF26324A)
                                            : const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        currency.symbol,
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currency.name,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Selection indicator checkmark
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: isDark
                                  ? AppColors.accentCyanBright
                                  : AppColors.primaryBlue,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ];
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current.flag,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    current.code,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    current.symbol,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ── Real-Time Data Refresh Button ─────────────────────────────────────────────
class _RefreshButton extends StatefulWidget {
  final VoidCallback? onRefresh;

  const _RefreshButton({this.onRefresh});

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _triggerRefresh() {
    if (_rotationController.isAnimating) return;
    _rotationController.forward(from: 0.0);

    if (widget.onRefresh != null) {
      widget.onRefresh!();
    } else {
      context.read<CryptoListBloc>().add(const FetchCryptoListEvent());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.accentCyanBright : AppColors.primaryBlue)
                    .withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bolt_rounded,
                color: isDark ? AppColors.accentCyanBright : AppColors.primaryBlue,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Refreshing live crypto market quotes...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF151D2A) : Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? const Color(0xFF2E3D56) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2E) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2A364F) : const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: IconButton(
        iconSize: 18,
        padding: EdgeInsets.zero,
        tooltip: 'Refresh Market Rates',
        icon: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: Icon(
                Icons.sync_rounded,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                size: 18,
              ),
            );
          },
        ),
        onPressed: _triggerRefresh,
      ),
    );
  }
}
