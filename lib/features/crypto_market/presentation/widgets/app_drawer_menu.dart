import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../settings/presentation/state/settings_cubit.dart';

class DrawerMenuItemData {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final List<DrawerSubMenuItemData>? subItems;

  const DrawerMenuItemData({
    required this.icon,
    required this.title,
    this.trailing,
    this.subItems,
  });
}

class DrawerSubMenuItemData {
  final String title;
  final VoidCallback onTap;

  const DrawerSubMenuItemData({required this.title, required this.onTap});
}

class AppDrawerMenu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexSelected;
  final bool isDesktop;
  final double? drawerWidth;
  final VoidCallback? onCloseDrawer;

  const AppDrawerMenu({
    super.key,
    required this.selectedIndex,
    required this.onIndexSelected,
    this.isDesktop = false,
    this.drawerWidth,
    this.onCloseDrawer,
  });

  @override
  State<AppDrawerMenu> createState() => _AppDrawerMenuState();
}

class _AppDrawerMenuState extends State<AppDrawerMenu> {
  bool _isMarketExpanded = true;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryAccent = widget.isDesktop
        ? (isDark ? AppColors.accentCyanBright : AppColors.primaryBlue)
        : (isDark ? AppColors.accentCyanBright : Colors.white);
    final drawerBg = widget.isDesktop
        ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
        : Colors.transparent;
    final borderColor = widget.isDesktop
        ? (isDark ? AppColors.borderDark : AppColors.borderLight)
        : Colors.transparent;
    final textPrimary = widget.isDesktop
        ? theme.colorScheme.onSurface
        : Colors.white;
    final textSecondary = widget.isDesktop
        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
        : Colors.white.withValues(alpha: 0.8);

    final effectiveWidth = widget.isDesktop
        ? 280.0
        : (widget.drawerWidth ?? 250.0);

    return Container(
      width: effectiveWidth,
      decoration: BoxDecoration(
        color: drawerBg,
        border: Border(
          right: BorderSide(
            color: borderColor,
            width: widget.isDesktop ? 1 : 0,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isDesktop ? 16 : 14,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Profile / App Header ─────────────────────────────────────────
              _buildProfileHeader(
                context: context,
                isDark: isDark,
                primaryAccent: primaryAccent,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),

              const SizedBox(height: 24),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 16),

              // ── 2. Navigation Items ─────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Item 0: Market Terminal
                      _buildDrawerMenuItem(
                        index: 0,
                        icon: Icons.show_chart_rounded,
                        title: 'Crypto Market',
                        isSelected: widget.selectedIndex == 0,
                        isDark: isDark,
                        primaryAccent: primaryAccent,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        trailing: widget.isDesktop
                            ? Icon(
                                _isMarketExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: primaryAccent,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          widget.onIndexSelected(0);
                          if (widget.isDesktop) {
                            setState(() {
                              _isMarketExpanded = !_isMarketExpanded;
                            });
                          }
                          widget.onCloseDrawer?.call();
                        },
                      ),

                      // Expandable Market Sub-Items
                      if (_isMarketExpanded)
                        Padding(
                          padding: const EdgeInsets.only(left: 28, bottom: 8),
                          child: Column(
                            children: [
                              _buildSubMenuItem(
                                title: 'Top Popular Coins',
                                isDark: isDark,
                                primaryAccent: primaryAccent,
                                textSecondary: textSecondary,
                                onTap: () {
                                  widget.onIndexSelected(0);
                                  widget.onCloseDrawer?.call();
                                },
                              ),
                              _buildSubMenuItem(
                                title: 'Live Price Charts',
                                isDark: isDark,
                                primaryAccent: primaryAccent,
                                textSecondary: textSecondary,
                                onTap: () {
                                  widget.onIndexSelected(0);
                                  widget.onCloseDrawer?.call();
                                },
                              ),
                            ],
                          ),
                        ),

                      // Item 1: Watchlist
                      _buildDrawerMenuItem(
                        index: 1,
                        icon: Icons.star_rounded,
                        title: 'Watchlist',
                        isSelected: widget.selectedIndex == 1,
                        isDark: isDark,
                        primaryAccent: primaryAccent,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          widget.onIndexSelected(1);
                          widget.onCloseDrawer?.call();
                        },
                      ),

                      // Item 2: Market Overview / Stats
                      _buildDrawerMenuItem(
                        index: 2,
                        icon: Icons.insights_rounded,
                        title: 'Market Overview',
                        isSelected: widget.selectedIndex == 2,
                        isDark: isDark,
                        primaryAccent: primaryAccent,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          widget.onIndexSelected(2);
                          widget.onCloseDrawer?.call();
                        },
                      ),

                      // Item 3: Settings
                      _buildDrawerMenuItem(
                        index: 3,
                        icon: Icons.settings_rounded,
                        title: 'Settings & Preferences',
                        isSelected: widget.selectedIndex == 3,
                        isDark: isDark,
                        primaryAccent: primaryAccent,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          widget.onIndexSelected(3);
                          widget.onCloseDrawer?.call();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 12),

              // ── 3. Footer Control Bar (Theme Switcher) ──────────────────────────
              _buildFooterControls(
                context: context,
                isDark: isDark,
                primaryAccent: primaryAccent,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required BuildContext context,
    required bool isDark,
    required Color primaryAccent,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                primaryAccent,
                isDark ? AppColors.primaryBlue : AppColors.accentCyan,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryAccent.withValues(alpha: 0.35),
                blurRadius: 10,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: isDark ? AppColors.cardDark : Colors.white,
            child: Icon(
              Icons.currency_bitcoin_rounded,
              color: isDark
                  ? AppColors.accentCyanBright
                  : AppColors.primaryBlue,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crypto Mart',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Live Market Intelligence',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required bool isSelected,
    required bool isDark,
    required Color primaryAccent,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryAccent.withValues(alpha: 0.18)
                : (isHovered
                      ? primaryAccent.withValues(alpha: 0.08)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected || isHovered
                  ? primaryAccent.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Glowing Left Indicator Line
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? primaryAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryAccent.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                icon,
                color: isSelected || isHovered ? primaryAccent : textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected || isHovered
                        ? textPrimary
                        : textSecondary,
                    fontSize: 14,
                    fontWeight: isSelected || isHovered
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuItem({
    required String title,
    required bool isDark,
    required Color primaryAccent,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        child: Row(
          children: [
            Icon(
              Icons.subdirectory_arrow_right_rounded,
              color: primaryAccent,
              size: 14,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterControls({
    required BuildContext context,
    required bool isDark,
    required Color primaryAccent,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final cardBg = widget.isDesktop
        ? primaryAccent.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.15);
    final cardBorder = widget.isDesktop
        ? primaryAccent.withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.25);
    final iconColor = widget.isDesktop ? primaryAccent : Colors.white;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isDesktop ? 12 : 10,
            vertical: widget.isDesktop ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isDark ? 'Dark Theme' : 'Light Theme',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: widget.isDesktop ? 13 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Switch.adaptive(
                value: isDark,
                activeThumbColor: iconColor,
                onChanged: (val) {
                  context.read<SettingsCubit>().changeThemeMode(
                    val ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
