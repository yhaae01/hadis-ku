import 'package:flutter/material.dart';

/// Tema Material 3 bernuansa Islami: hijau tua elegan, permukaan putih
/// kehijauan, dan aksen emas.
class AppTheme {
  AppTheme._();

  static const Color green = Color(0xFF0B5D3B);
  static const Color deepGreen = Color(0xFF063D27);
  static const Color gold = Color(0xFFC9A227);
  static const Color surface = Color(0xFFF4F9F5);
  static const Color border = Color(0xFFE2ECE5);

  static const ColorScheme _scheme = ColorScheme(
    brightness: Brightness.light,
    primary: green,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD8EFE2),
    onPrimaryContainer: deepGreen,
    secondary: gold,
    onSecondary: Color(0xFF2C2000),
    secondaryContainer: Color(0xFFF6EBC6),
    onSecondaryContainer: Color(0xFF3D3000),
    tertiary: Color(0xFF2F6B52),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFDCEFE5),
    onTertiaryContainer: Color(0xFF0B2C1E),
    error: Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: surface,
    onSurface: Color(0xFF17251D),
    surfaceDim: Color(0xFFD9E4DC),
    surfaceBright: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFF9FCFA),
    surfaceContainer: Color(0xFFEDF4EF),
    surfaceContainerHigh: Color(0xFFE7F0EA),
    surfaceContainerHighest: Color(0xFFE1EBE4),
    onSurfaceVariant: Color(0xFF52635A),
    outline: Color(0xFF8A9A90),
    outlineVariant: border,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2B3830),
    onInverseSurface: Color(0xFFEDF5EF),
    inversePrimary: Color(0xFF8FD5B2),
    surfaceTint: green,
  );

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, colorScheme: _scheme);
    final textTheme = base.textTheme
        .apply(
          bodyColor: _scheme.onSurface,
          displayColor: _scheme.onSurface,
        )
        .copyWith(
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.5),
          labelLarge: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: deepGreen,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: deepGreen),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: _scheme.onSurfaceVariant),
        prefixIconColor: _scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: green),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: green,
        linearTrackColor: Color(0xFFD8EFE2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: deepGreen,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
