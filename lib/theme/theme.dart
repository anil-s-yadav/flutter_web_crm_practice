import "package:flutter/material.dart";
import "package:practice_app/theme/app_colors.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.navyBlue,
      surfaceTint: AppColors.navyBlue,
      onPrimary: AppColors.white,
      primaryContainer: Color(0xFF2B5278),
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.lightGold,
      onSecondaryContainer: Color(0xFF3D3010),
      tertiary: Color(0xFF4A6741),
      onTertiary: AppColors.white,
      tertiaryContainer: Color(0xFFCCEEBD),
      onTertiaryContainer: Color(0xFF072105),
      error: AppColors.criticalRed,
      onError: AppColors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: Color(0xFF4A4640),
      outline: Color(0xFF7A756C),
      outlineVariant: Color(0xFFCBC5BC),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: AppColors.navyBlue,
      inversePrimary: Color(0xFFB4CFEA),
      primaryFixed: Color(0xFFD6E3F5),
      onPrimaryFixed: AppColors.navyBlue,
      primaryFixedDim: Color(0xFFAAC7E5),
      onPrimaryFixedVariant: Color(0xFF1B3A5C),
      secondaryFixed: AppColors.lightGold,
      onSecondaryFixed: Color(0xFF3D3010),
      secondaryFixedDim: AppColors.gold,
      onSecondaryFixedVariant: Color(0xFF6B5820),
      tertiaryFixed: Color(0xFFCCEEBD),
      onTertiaryFixed: Color(0xFF072105),
      tertiaryFixedDim: Color(0xFFB0D2A2),
      onTertiaryFixedVariant: Color(0xFF334F2B),
      surfaceDim: Color(0xFFE0DCD4),
      surfaceBright: AppColors.surfaceLight,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: Color(0xFFF7F4EF),
      surfaceContainer: Color(0xFFF0ECE6),
      surfaceContainerHigh: Color(0xFFEAE6E0),
      surfaceContainerHighest: Color(0xFFE4E0DA),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFB4CFEA),
      surfaceTint: Color(0xFFB4CFEA),
      onPrimary: AppColors.darkNavy,
      primaryContainer: AppColors.navyBlue,
      onPrimaryContainer: Color(0xFFD6E3F5),
      secondary: AppColors.goldLight,
      onSecondary: Color(0xFF3D3010),
      secondaryContainer: Color(0xFF6B5820),
      onSecondaryContainer: AppColors.lightGold,
      tertiary: Color(0xFFB0D2A2),
      onTertiary: Color(0xFF1D3716),
      tertiaryContainer: Color(0xFF334F2B),
      onTertiaryContainer: Color(0xFFCCEEBD),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: Color(0xFFCBC5BC),
      outline: Color(0xFF948F86),
      outlineVariant: Color(0xFF4A4640),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE8E4DC),
      inversePrimary: AppColors.navyBlue,
      primaryFixed: Color(0xFFD6E3F5),
      onPrimaryFixed: Color(0xFF0A1E32),
      primaryFixedDim: Color(0xFFB4CFEA),
      onPrimaryFixedVariant: Color(0xFF1B3A5C),
      secondaryFixed: AppColors.lightGold,
      onSecondaryFixed: Color(0xFF3D3010),
      secondaryFixedDim: AppColors.gold,
      onSecondaryFixedVariant: Color(0xFF6B5820),
      tertiaryFixed: Color(0xFFCCEEBD),
      onTertiaryFixed: Color(0xFF072105),
      tertiaryFixedDim: Color(0xFFB0D2A2),
      onTertiaryFixedVariant: Color(0xFF334F2B),
      surfaceDim: AppColors.surfaceDark,
      surfaceBright: Color(0xFF384858),
      surfaceContainerLowest: Color(0xFF16202D),
      surfaceContainerLow: Color(0xFF1F2D40),
      surfaceContainer: AppColors.cardDark,
      surfaceContainerHigh: AppColors.darkSurfaceVariant,
      surfaceContainerHighest: Color(0xFF3D536E),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    final bool isLight = colorScheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: isLight ? 1 : 0,
        shadowColor: isLight
            ? AppColors.navyBlue.withValues(alpha: 0.06)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: isLight ? AppColors.cardLight : AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: isLight ? AppColors.navyBlue : AppColors.surfaceDark,
        foregroundColor: AppColors.white,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navyBlue,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isLight ? AppColors.navyBlue : AppColors.goldLight,
          side: BorderSide(
            color: isLight ? AppColors.navyBlue.withValues(alpha: 0.3) : AppColors.goldLight.withValues(alpha: 0.4),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isLight ? AppColors.navyBlue : AppColors.goldLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? AppColors.white
            : AppColors.navyDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isLight ? AppColors.dividerLight : AppColors.dividerDark,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isLight ? AppColors.dividerLight : AppColors.dividerDark,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isLight ? AppColors.navyBlue : AppColors.goldLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.criticalRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.criticalRed, width: 2),
        ),
        hintStyle: TextStyle(
          color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
        ),
        prefixIconColor: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(
          isLight ? AppColors.navyBlue.withValues(alpha: 0.04) : AppColors.cardDark,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return isLight
                ? AppColors.gold.withValues(alpha: 0.06)
                : AppColors.navyLight.withValues(alpha: 0.2);
          }
          return null;
        }),
        headingTextStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isLight ? AppColors.navyBlue : AppColors.textPrimaryDark,
        ),
        dividerThickness: 1,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isLight ? AppColors.navyBlue : AppColors.navyDark,
        selectedIconTheme: const IconThemeData(color: AppColors.gold),
        unselectedIconTheme: IconThemeData(
          color: AppColors.white.withValues(alpha: 0.6),
        ),
        indicatorColor: AppColors.gold.withValues(alpha: 0.15),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: isLight ? AppColors.grey500 : AppColors.grey400,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isLight ? AppColors.white : AppColors.cardDark,
        selectedItemColor: isLight ? AppColors.navyBlue : AppColors.goldLight,
        unselectedItemColor: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isLight ? AppColors.dividerLight : AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? AppColors.surfaceLight
            : AppColors.cardDark,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(
          color: isLight ? AppColors.dividerLight : AppColors.dividerDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isLight ? AppColors.white : AppColors.cardDark,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? AppColors.navyBlue : AppColors.cardDark,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight ? AppColors.navyBlue : AppColors.cardDark,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: AppColors.white),
      ),
    );
  }

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
