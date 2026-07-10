import 'package:flutter/material.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;

    if (isDark) {
      return Container(
        color: AppColors.darkSurface,
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white,
            AppColors.white,
            AppColors.lightGold.withValues(alpha: 0.4),
            AppColors.white,
            AppColors.navyBlue.withValues(alpha: 0.04),
          ],
          stops: const [0.0, 0.4, 0.6, 0.8, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyBlue.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
