import 'package:flutter/material.dart';

class AppColors {
  // Brand specific colors from Stitch Design System
  static const Color primary = Color(0xFF166C44);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF68B789);
  static const Color onPrimaryContainer = Color(0xFF004629);

  static const Color secondary = Color(0xFF006780);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF77DCFF);
  static const Color onSecondaryContainer = Color(0xFF006077);

  static const Color tertiary = Color(0xFF94464F);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFEB8C95);
  static const Color onTertiaryContainer = Color(0xFF6A252F);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color surface = Color(0xFFF6FAF6);
  static const Color onSurface = Color(0xFF181D1A);
  static const Color surfaceVariant = Color(0xFFDFE3E0);
  static const Color onSurfaceVariant = Color(0xFF3F4942);

  static const Color outline = Color(0xFF6F7A71);
  static const Color outlineVariant = Color(0xFFBFC9BF);
  static const Color inverseSurface = Color(0xFF2D312F);
  static const Color onInverseSurface = Color(0xFFEEF2EE);
  static const Color inversePrimary = Color(0xFF87D7A7);

  static const Color shadow = Color(0x0F166C44); // 0.06 opacity green-tinted shadow from design md
  static const Color scrim = Color(0xFF000000);

  // Light Mode Color Scheme mapped directly from Stitch namedColors
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceVariant,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: shadow,
    scrim: scrim,
    inverseSurface: inverseSurface,
    onInverseSurface: onInverseSurface,
    inversePrimary: inversePrimary,
  );

  // Dark Mode Color Scheme generated from seed color based on the primary hex
  // since only Light Mode was explicitly provided in the design system rules
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.dark,
  ).copyWith(
    // Ensure key brand colors are represented, adapting to dark surface standards
    primary: inversePrimary,
    onPrimary: onPrimaryContainer,
    primaryContainer: primary.withOpacity(0.5),
    secondary: secondaryContainer,
    surface: const Color(0xFF181D1A), // Reversal of surface for dark background
  );
}
