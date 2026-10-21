import 'package:flutter/material.dart';

import 'brand.dart';

class AppTheme {
  AppTheme._();

  /// Hind Siliguri is used for Bangla; Inter for English. Each is the primary
  /// family and the other is a fallback, so mixed text renders correctly.
  static String fontFor(Locale locale) =>
      locale.languageCode == 'bn' ? 'HindSiliguri' : 'Inter';

  static ThemeData light(Locale locale) => _build(Brightness.light, locale);
  static ThemeData dark(Locale locale) => _build(Brightness.dark, locale);

  static ThemeData _build(Brightness b, Locale locale) {
    final bool isDark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: Brand.primary, brightness: b)
        .copyWith(
          primary: isDark ? Brand.primaryDark : Brand.primary,
          onPrimary: isDark ? const Color(0xFF0E1020) : Colors.white,
          surface: isDark ? const Color(0xFF12141C) : Colors.white,
          error: isDark ? const Color(0xFFFF8A8A) : Brand.danger,
        );
    final family = fontFor(locale);
    final fallback = <String>[family == 'Inter' ? 'HindSiliguri' : 'Inter'];
    final base = ThemeData(
      brightness: b,
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: family,
      fontFamilyFallback: fallback,
    );
    final Color scaffold = isDark
        ? const Color(0xFF0C0E14)
        : const Color(0xFFF6F7FB);
    final Color border = isDark
        ? const Color(0xFF2A2E3B)
        : const Color(0xFFE3E6EE);
    final Color cardColor = isDark ? const Color(0xFF161923) : Colors.white;

    OutlineInputBorder outline(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(Brand.rMd),
      borderSide: BorderSide(color: c, width: w),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      dividerColor: border,
      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: family,
          fontFamilyFallback: fallback,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Brand.rLg),
          side: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: outline(border),
        enabledBorder: outline(border),
        focusedBorder: outline(scheme.primary, 1.6),
        errorBorder: outline(scheme.error),
        focusedErrorBorder: outline(scheme.error, 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Brand.rMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Brand.rMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 66,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Brand.rSm),
        ),
        backgroundColor: cardColor,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Brand.rLg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Brand.rMd),
        ),
      ),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.zero),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.primary : null,
        ),
      ),
    );
  }
}
