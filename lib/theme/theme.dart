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
      primaryContainer: Color(0xFF1A3A5C),
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.navyBlue,
      secondaryContainer: AppColors.lightGold,
      onSecondaryContainer: Color(0xFF3D2E00),
      tertiary: Color(0xFF4A6741),
      onTertiary: AppColors.white,
      tertiaryContainer: Color(0xFFCCEEBD),
      onTertiaryContainer: Color(0xFF072105),
      error: AppColors.criticalRed,
      onError: AppColors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: AppColors.surfaceLight,
      onSurface: Color(0xFF1A1A2E),
      onSurfaceVariant: Color(0xFF44474E),
      outline: Color(0xFF74777F),
      outlineVariant: Color(0xFFC4C6D0),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2E3036),
      inversePrimary: Color(0xFFAAC7FF),
      primaryFixed: Color(0xFFD6E3FF),
      onPrimaryFixed: AppColors.navyBlue,
      primaryFixedDim: Color(0xFFAAC7FF),
      onPrimaryFixedVariant: Color(0xFF284777),
      secondaryFixed: AppColors.lightGold,
      onSecondaryFixed: Color(0xFF3D2E00),
      secondaryFixedDim: AppColors.gold,
      onSecondaryFixedVariant: Color(0xFF5C4A00),
      tertiaryFixed: Color(0xFFCCEEBD),
      onTertiaryFixed: Color(0xFF072105),
      tertiaryFixedDim: Color(0xFFB0D2A2),
      onTertiaryFixedVariant: Color(0xFF334F2B),
      surfaceDim: Color(0xFFD9D9E0),
      surfaceBright: AppColors.surfaceLight,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: Color(0xFFF3F3FA),
      surfaceContainer: Color(0xFFEDEDF4),
      surfaceContainerHigh: Color(0xFFE7E8EE),
      surfaceContainerHighest: Color(0xFFE2E2E9)
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFAAC7FF),
      surfaceTint: Color(0xFFAAC7FF),
      onPrimary: AppColors.darkNavy,
      primaryContainer: AppColors.navyBlue,
      onPrimaryContainer: Color(0xFFD6E3FF),
      secondary: AppColors.gold,
      onSecondary: Color(0xFF3D2E00),
      secondaryContainer: Color(0xFF5C4A00),
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
      onSurface: Color(0xFFE2E2E9),
      onSurfaceVariant: Color(0xFFC4C6D0),
      outline: Color(0xFF8E9099),
      outlineVariant: Color(0xFF44474E),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE2E2E9),
      inversePrimary: AppColors.navyBlue,
      primaryFixed: Color(0xFFD6E3FF),
      onPrimaryFixed: Color(0xFF001B3E),
      primaryFixedDim: Color(0xFFAAC7FF),
      onPrimaryFixedVariant: Color(0xFF284777),
      secondaryFixed: AppColors.lightGold,
      onSecondaryFixed: Color(0xFF3D2E00),
      secondaryFixedDim: AppColors.gold,
      onSecondaryFixedVariant: Color(0xFF5C4A00),
      tertiaryFixed: Color(0xFFCCEEBD),
      onTertiaryFixed: Color(0xFF072105),
      tertiaryFixedDim: Color(0xFFB0D2A2),
      onTertiaryFixedVariant: Color(0xFF334F2B),
      surfaceDim: AppColors.surfaceDark,
      surfaceBright: Color(0xFF37393E),
      surfaceContainerLowest: Color(0xFF0C0E13),
      surfaceContainerLow: Color(0xFF191C20),
      surfaceContainer: Color(0xFF1D2024),
      surfaceContainerHigh: Color(0xFF282A2F),
      surfaceContainerHighest: Color(0xFF33353A)
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF133665),
      surfaceTint: AppColors.navyBlue,
      onPrimary: AppColors.white,
      primaryContainer: Color(0xFF506DA0),
      onPrimaryContainer: AppColors.white,
      secondary: Color(0xFF5C4A00),
      onSecondary: AppColors.white,
      secondaryContainer: Color(0xFF8A7530),
      onSecondaryContainer: AppColors.white,
      tertiary: Color(0xFF334F2B),
      onTertiary: AppColors.white,
      tertiaryContainer: Color(0xFF5F7D56),
      onTertiaryContainer: AppColors.white,
      error: Color(0xFF740006),
      onError: AppColors.white,
      errorContainer: Color(0xFFCF2C27),
      onErrorContainer: AppColors.white,
      surface: AppColors.surfaceLight,
      onSurface: Color(0xFF0F1116),
      onSurfaceVariant: Color(0xFF33363E),
      outline: Color(0xFF4F525A),
      outlineVariant: Color(0xFF6A6D75),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2E3036),
      inversePrimary: Color(0xFFAAC7FF),
      primaryFixed: Color(0xFF506DA0),
      onPrimaryFixed: AppColors.white,
      primaryFixedDim: Color(0xFF375586),
      onPrimaryFixedVariant: AppColors.white,
      secondaryFixed: Color(0xFF8A7530),
      onSecondaryFixed: AppColors.white,
      secondaryFixedDim: Color(0xFF6F5D19),
      onSecondaryFixedVariant: AppColors.white,
      tertiaryFixed: Color(0xFF5F7D56),
      onTertiaryFixed: AppColors.white,
      tertiaryFixedDim: Color(0xFF47643F),
      onTertiaryFixedVariant: AppColors.white,
      surfaceDim: Color(0xFFC5C6CD),
      surfaceBright: AppColors.surfaceLight,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: Color(0xFFF3F3FA),
      surfaceContainer: Color(0xFFE7E8EE),
      surfaceContainerHigh: Color(0xFFDCDCE3),
      surfaceContainerHighest: Color(0xFFD1D1D8)
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFCDDDFF),
      surfaceTint: Color(0xFFAAC7FF),
      onPrimary: Color(0xFF002551),
      primaryContainer: Color(0xFF7491C7),
      onPrimaryContainer: Color(0xFF000000),
      secondary: Color(0xFFEECC5E),
      onSecondary: Color(0xFF2D2100),
      secondaryContainer: Color(0xFFA08A3A),
      onSecondaryContainer: Color(0xFF000000),
      tertiary: Color(0xFFC5E8B6),
      onTertiary: Color(0xFF0F2B0A),
      tertiaryContainer: Color(0xFF7B9B6F),
      onTertiaryContainer: Color(0xFF000000),
      error: Color(0xFFFFD2CC),
      onError: Color(0xFF540003),
      errorContainer: Color(0xFFFF5449),
      onErrorContainer: Color(0xFF000000),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.white,
      onSurfaceVariant: Color(0xFFDADCE6),
      outline: Color(0xFFAFB2BB),
      outlineVariant: Color(0xFF8E9099),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE2E2E9),
      inversePrimary: Color(0xFF294878),
      primaryFixed: Color(0xFFD6E3FF),
      onPrimaryFixed: Color(0xFF00112B),
      primaryFixedDim: Color(0xFFAAC7FF),
      onPrimaryFixedVariant: Color(0xFF133665),
      secondaryFixed: AppColors.lightGold,
      onSecondaryFixed: Color(0xFF1A1300),
      secondaryFixedDim: AppColors.gold,
      onSecondaryFixedVariant: Color(0xFF483800),
      tertiaryFixed: Color(0xFFCCEEBD),
      onTertiaryFixed: Color(0xFF021602),
      tertiaryFixedDim: Color(0xFFB0D2A2),
      onTertiaryFixedVariant: Color(0xFF233E1C),
      surfaceDim: AppColors.surfaceDark,
      surfaceBright: Color(0xFF43444A),
      surfaceContainerLowest: Color(0xFF06070C),
      surfaceContainerLow: Color(0xFF1B1E22),
      surfaceContainer: Color(0xFF26282D),
      surfaceContainerHigh: Color(0xFF313238),
      surfaceContainerHighest: Color(0xFF3C3E43)
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    final bool isLight = colorScheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
        ),
        color: isLight ? AppColors.cardLight : AppColors.cardDark,
        surfaceTintColor: Colors.transparent
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: isLight ? AppColors.navyBlue : AppColors.surfaceDark,
        foregroundColor: AppColors.white,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600
        ),
        iconTheme: const IconThemeData(color: AppColors.white)
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navyBlue,
          elevation: 2,
          shadowColor: AppColors.gold.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600
          )
        )
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isLight ? AppColors.navyBlue : AppColors.gold,
          side: BorderSide(
            color: isLight ? AppColors.navyBlue : AppColors.gold,
            width: 1.5
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          )
        )
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isLight ? AppColors.navyBlue : AppColors.gold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
          )
        )
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? AppColors.white
            : AppColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isLight ? AppColors.dividerLight : AppColors.dividerDark
          )
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isLight ? AppColors.dividerLight : AppColors.dividerDark
          )
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 2)
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.criticalRed)
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.criticalRed, width: 2)
        ),
        hintStyle: TextStyle(
          color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark
        ),
        prefixIconColor: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(
          isLight ? AppColors.navyBlue.withValues(alpha: 0.05) : AppColors.cardDark
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return isLight
                ? AppColors.lightGold.withValues(alpha: 0.3)
                : AppColors.navyBlue.withValues(alpha: 0.3);
          }
          return null;
        }),
        headingTextStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isLight ? AppColors.navyBlue : AppColors.textPrimaryDark
        ),
        dividerThickness: 1
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isLight ? AppColors.navyBlue : AppColors.darkNavy,
        selectedIconTheme: const IconThemeData(color: AppColors.gold),
        unselectedIconTheme: IconThemeData(
          color: AppColors.white.withValues(alpha: 0.6)
        ),
        indicatorColor: AppColors.gold.withValues(alpha: 0.15)
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isLight ? AppColors.white : AppColors.cardDark,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12
        )
      ),
      dividerTheme: DividerThemeData(
        color: isLight ? AppColors.dividerLight : AppColors.dividerDark,
        thickness: 1,
        space: 1
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? AppColors.surfaceLight
            : AppColors.cardDark,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        side: BorderSide(
          color: isLight ? AppColors.dividerLight : AppColors.dividerDark
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navyBlue,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
        )
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        backgroundColor: isLight ? AppColors.white : AppColors.cardDark,
        elevation: 8
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? AppColors.navyBlue : AppColors.cardDark,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        ),
        behavior: SnackBarBehavior.floating
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight ? AppColors.navyBlue : AppColors.cardDark,
          borderRadius: BorderRadius.circular(8)
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: AppColors.white)
      )
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
    required this.darkMediumContrast
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
