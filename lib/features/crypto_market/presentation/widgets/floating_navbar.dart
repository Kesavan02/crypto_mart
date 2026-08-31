import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class FloatingNavbarItem {
  final String label;
  final IconData icon;

  const FloatingNavbarItem({
    required this.label,
    required this.icon,
  });
}

class FloatingNavbar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<FloatingNavbarItem> items;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const FloatingNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  State<FloatingNavbar> createState() => _FloatingNavbarState();
}

class _FloatingNavbarState extends State<FloatingNavbar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final primaryAccent = isDark ? AppColors.accentCyanBright : AppColors.primaryBlue;
    final navBg = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.9);
    final borderColor = isDark
        ? AppColors.borderDark.withValues(alpha: 0.8)
        : AppColors.borderLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    if (isMobile) {
      return _buildMobileFloatingPill(
        context: context,
        isDark: isDark,
        primaryAccent: primaryAccent,
        navBg: navBg,
        borderColor: borderColor,
        textMuted: textMuted,
      );
    }

    return _buildDesktopFloatingHeader(
      context: context,
      isDark: isDark,
      primaryAccent: primaryAccent,
      navBg: navBg,
      borderColor: borderColor,
      textMuted: textMuted,
    );
  }

  Widget _buildMobileFloatingPill({
    required BuildContext context,
    required bool isDark,
    required Color primaryAccent,
    required Color navBg,
    required Color borderColor,
    required Color textMuted,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: navBg,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? primaryAccent.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final isSelected = widget.selectedIndex == index;

                return GestureDetector(
                  onTap: () => widget.onItemSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryAccent.withValues(alpha: 0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? primaryAccent.withValues(alpha: 0.6)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: isSelected ? primaryAccent : textMuted,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                                  : textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopFloatingHeader({
    required BuildContext context,
    required bool isDark,
    required Color primaryAccent,
    required Color navBg,
    required Color borderColor,
    required Color textMuted,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: navBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? primaryAccent.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryAccent.withValues(alpha: 0.5)),
                    ),
                    child: Icon(
                      Icons.currency_bitcoin_rounded,
                      color: primaryAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text.rich(
                    TextSpan(
                      text: 'Crypto',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Mart',
                          style: TextStyle(
                            color: primaryAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Nav Items
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  final isSelected = widget.selectedIndex == index;
                  final isHovered = _hoveredIndex == index;

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _hoveredIndex = index),
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: GestureDetector(
                      onTap: () => widget.onItemSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryAccent.withValues(alpha: 0.2)
                              : (isHovered
                                  ? primaryAccent.withValues(alpha: 0.1)
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected || isHovered
                                ? primaryAccent.withValues(alpha: 0.6)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: 18,
                              color: isSelected || isHovered ? primaryAccent : textMuted,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected || isHovered
                                    ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                                    : textMuted,
                                fontSize: 14,
                                fontWeight: isSelected || isHovered
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // Action Button (if provided)
              if (widget.actionLabel != null && widget.onActionTap != null)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onActionTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryAccent,
                            primaryAccent.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryAccent.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.actionLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
