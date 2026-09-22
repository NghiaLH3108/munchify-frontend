import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ColorPalette.dart';
import 'AppTypography.dart';

/// Munchify POS application theme.
///
/// Usage in [MaterialApp]:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   ...
/// )
/// ```
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',

      // ─── Color Scheme ────────────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: ColorPalette.appetizingOrange,
        onPrimary: ColorPalette.onPrimary,
        primaryContainer: Color(0xFFFFCCBC),
        onPrimaryContainer: Color(0xFF5D1500),
        secondary: ColorPalette.amber,
        onSecondary: ColorPalette.warmDarkGrey,
        secondaryContainer: Color(0xFFFFECB3),
        onSecondaryContainer: Color(0xFF4A3000),
        surface: ColorPalette.surface,
        onSurface: ColorPalette.onSurface,
        surfaceContainerHighest: ColorPalette.surfaceVariant,
        error: ColorPalette.error,
        onError: ColorPalette.onError,
        outline: ColorPalette.border,
      ),

      scaffoldBackgroundColor: ColorPalette.background,

      // ─── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorPalette.appetizingOrange,
        foregroundColor: ColorPalette.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ColorPalette.onPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // ─── Elevated Button (primary CTA) ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.appetizingOrange,
          foregroundColor: ColorPalette.onPrimary,
          disabledBackgroundColor: ColorPalette.textDisabled,
          minimumSize: const Size(48, 48), // AI Guide §6: min touch target
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLarge,
          elevation: 2,
        ),
      ),

      // ─── Outlined Button ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.appetizingOrange,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(
            color: ColorPalette.appetizingOrange,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ─── Text Button ─────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorPalette.appetizingOrange,
          minimumSize: const Size(48, 48),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ─── Icon Button ─────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),

      // ─── Input Fields ─────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorPalette.appetizingOrange,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: ColorPalette.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: ColorPalette.textHint,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: ColorPalette.textSecondary,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: ColorPalette.error,
        ),
      ),

      // ─── Filter Chips (category tabs) ─────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: ColorPalette.surfaceVariant,
        selectedColor: ColorPalette.appetizingOrange,
        disabledColor: ColorPalette.surfaceVariant,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle:
            AppTypography.labelMedium.copyWith(color: ColorPalette.onPrimary),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ─── Cards ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: ColorPalette.surface,
        elevation: 2,
        shadowColor: ColorPalette.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── Dividers ─────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: ColorPalette.divider,
        thickness: 1,
        space: 1,
      ),

      // ─── Bottom Sheet ─────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorPalette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
      ),

      // ─── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorPalette.warmDarkGrey,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        actionTextColor: ColorPalette.amber,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ─── Navigation Bar (bottom nav) ──────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorPalette.surface,
        indicatorColor: ColorPalette.appetizingOrange.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: ColorPalette.appetizingOrange,
            );
          }
          return AppTypography.labelSmall;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: ColorPalette.appetizingOrange);
          }
          return const IconThemeData(color: ColorPalette.textSecondary);
        }),
        elevation: 8,
      ),

      // ─── Progress Indicator ───────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColorPalette.appetizingOrange,
        linearTrackColor: ColorPalette.surfaceVariant,
      ),

      // ─── Text Theme ───────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
    );
  }
}
