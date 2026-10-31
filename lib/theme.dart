import 'package:flutter/material.dart';

/// Bảng màu "Wabi-Sabi": giấy washi, mực sumi. Màu nhấn lấy theo cấp đang học (JlptLevel.color).
class AppColors {
  static const paper = Color(0xFFFBF9F4);
  static const ink = Color(0xFF1F1E1C);
  static const line = Color(0xFFE5DFD3);
  static const night = Color(0xFF1C1B19);
  static const nightLine = Color(0xFF3A3833);
  static const correct = Color(0xFF2E9E5B);
}

/// Locale tiếng Nhật để Kanji hiển thị đúng nét kiểu Nhật (không phải kiểu Trung).
const kJapanese = Locale('ja', 'JP');

const _serif = 'NotoSerif';
const _sans = 'BeVietnamPro';

/// Kiểu chữ cho Kanji/kana: dùng font hệ thống (Hiragino / Noto CJK) với locale tiếng Nhật.
TextStyle kanjiStyle(double size, {FontWeight? weight, Color? color}) => TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      locale: kJapanese,
      fontFamilyFallback: const ['Hiragino Mincho ProN', 'Noto Serif CJK JP', 'Noto Sans CJK JP'],
    );

ThemeData buildTheme(Brightness brightness, {required Color accent}) {
  final isLight = brightness == Brightness.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  ).copyWith(
    primary: accent,
    onPrimary: Colors.white,
    surface: isLight ? AppColors.paper : AppColors.night,
    onSurface: isLight ? AppColors.ink : const Color(0xFFEDEAE3),
    outlineVariant: isLight ? AppColors.line : AppColors.nightLine,
  );
  final base = ThemeData(brightness: brightness, fontFamily: _sans).textTheme;
  TextStyle? serif(TextStyle? s) => s?.copyWith(fontFamily: _serif, fontWeight: FontWeight.w600);
  final textTheme = base
      .copyWith(
        displayLarge: serif(base.displayLarge),
        displayMedium: serif(base.displayMedium),
        displaySmall: serif(base.displaySmall),
        headlineLarge: serif(base.headlineLarge),
        headlineMedium: serif(base.headlineMedium),
        headlineSmall: serif(base.headlineSmall),
        titleLarge: serif(base.titleLarge),
      )
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  final bg = isLight ? AppColors.paper : AppColors.night;
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: _sans,
    textTheme: textTheme,
    scaffoldBackgroundColor: bg,
    dividerColor: scheme.outlineVariant,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: _serif,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: isLight ? Colors.white : const Color(0xFF262521),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bg,
      indicatorColor: accent.withValues(alpha: 0.14),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: _sans, fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: shape,
        textStyle: const TextStyle(fontFamily: _sans, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: shape,
        textStyle: const TextStyle(fontFamily: _sans, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
