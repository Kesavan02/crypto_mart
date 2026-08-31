import 'package:flutter/material.dart';

class CustomRoundedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double height;

  const CustomRoundedAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.height = 64.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Vibrant primary blue for Light mode (matching reference image), sleek dark navy for Dark mode
    final backgroundColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFF2563EB);

    return AppBar(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      toolbarHeight: height,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      leading: leading,
      title:
          titleWidget ??
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.3,
            ),
          ),
      actions: actions,
    );
  }
}
