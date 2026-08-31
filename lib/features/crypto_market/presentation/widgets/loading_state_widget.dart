import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class LoadingStateWidget extends StatelessWidget {
  final String? message;

  const LoadingStateWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final indicatorColor = isDark ? AppColors.accentCyanBright : AppColors.primaryBlue;
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: indicatorColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Fetching crypto market data...',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
