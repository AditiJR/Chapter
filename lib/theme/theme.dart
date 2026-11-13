import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens taken from the Chapter Figma file.
class ChapterColors {
  static const background = Color(0xfffff8f3);
  static const primary = Color(0xff7b2d3b);
  static const onPrimary = Color(0xffffffff);
  static const primaryContainer = Color(0xffffd9dd);
  static const onPrimaryContainer = Color(0xff3f0014);
  static const tertiaryContainer = Color(0xfff5e2a8);
  static const secondary = Color(0xff7a5649);
  static const secondaryContainer = Color(0xffffdbcf);
  static const onSecondaryContainer = Color(0xff2e150c);
  static const tertiary = Color(0xff6b5e2f);
  static const surfaceVariant = Color(0xfff4deda);
  static const surfaceContainerHigh = Color(0xfff3e7e1);
  static const onTertiaryContainer = Color(0xff231b00);
  static const surfaceContainer = Color(0xfff9ede7);
  static const onSurface = Color(0xff201a19);
  static const onSurfaceVariant = Color(0xff534341);
  static const outline = Color(0xff857371);
  static const outlineVariant = Color(0xffd8c2bf);
  static const success = Color(0xff3f6a3a);
  static const cameraBackground = Color(0xff2a211f);
  static const error = Color(0xffba1a1a);
}

class ChapterText {
  static TextStyle lora(
    double size,
    double height,
    FontWeight weight, {
    Color color = ChapterColors.onSurface,
  }) => GoogleFonts.lora(
    fontSize: size,
    height: height / size,
    fontWeight: weight,
    color: color,
  );

  static TextStyle roboto(
    double size,
    double height,
    FontWeight weight, {
    Color color = ChapterColors.onSurface,
  }) => GoogleFonts.roboto(
    fontSize: size,
    height: height / size,
    fontWeight: weight,
    color: color,
  );

  static TextStyle get headlineMedium =>
      lora(26, 34, FontWeight.w600); // Headline/Medium
  static TextStyle get titleLarge => lora(20, 28, FontWeight.w600);
  static TextStyle get titleMedium => roboto(16, 24, FontWeight.w500);
  static TextStyle get bodyLarge =>
      roboto(16, 24, FontWeight.w400, color: ChapterColors.onSurfaceVariant);
  static TextStyle get bodyMedium =>
      roboto(14, 20, FontWeight.w400, color: ChapterColors.onSurfaceVariant);
  static TextStyle get bodySmall =>
      roboto(12, 16, FontWeight.w400, color: ChapterColors.onSurfaceVariant);
  static TextStyle get labelLarge => roboto(14, 20, FontWeight.w500);
  static TextStyle get labelMedium => roboto(12, 16, FontWeight.w500);
  static TextStyle get labelSmall => roboto(11, 16, FontWeight.w500);
}

ThemeData chapterTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: ChapterColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: ChapterColors.primary,
        onPrimary: ChapterColors.onPrimary,
        primaryContainer: ChapterColors.primaryContainer,
        onPrimaryContainer: ChapterColors.onPrimaryContainer,
        secondary: ChapterColors.secondary,
        secondaryContainer: ChapterColors.secondaryContainer,
        onSecondaryContainer: ChapterColors.onSecondaryContainer,
        tertiary: ChapterColors.tertiary,
        surface: ChapterColors.background,
        onSurface: ChapterColors.onSurface,
        onSurfaceVariant: ChapterColors.onSurfaceVariant,
        outline: ChapterColors.outline,
        outlineVariant: ChapterColors.outlineVariant,
        error: ChapterColors.error,
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: ChapterColors.background,
  );
}
