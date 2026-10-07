import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/image_utils.dart';

class CoinIcon extends StatelessWidget {
  final String imageUrl;
  final String symbol;
  final double size;
  final BorderRadius? borderRadius;

  const CoinIcon({
    super.key,
    required this.imageUrl,
    required this.symbol,
    this.size = 36.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(size / 2);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.2),
        borderRadius: effectiveBorderRadius,
      ),
      child: Center(
        child: Text(
          symbol.isNotEmpty ? symbol.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: isDark ? AppColors.accentCyanBright : AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );

    final safeUrl = ImageUtils.getCORSFriendlyUrl(imageUrl);
    if (safeUrl.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: Image.network(
        safeUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark.withValues(alpha: 0.6)
                  : AppColors.cardLight.withValues(alpha: 0.6),
              borderRadius: effectiveBorderRadius,
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.45,
                height: size * 0.45,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: isDark
                      ? AppColors.accentCyanBright
                      : AppColors.primaryBlue,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // If the proxied URL failed, fallback to direct URL before final fallback
          if (safeUrl != imageUrl && imageUrl.isNotEmpty) {
            return Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            );
          }
          return placeholder;
        },
      ),
    );
  }
}
