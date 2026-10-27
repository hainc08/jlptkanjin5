import 'package:flutter/material.dart';

class AppColors {
  static const vermilion = Color(0xFFD7263D); // đỏ son
  static const plum = Color(0xFF8E1B3A);
  static const paper = Color(0xFFFFF8F0);
  static const night = Color(0xFF14141B);
  static const correct = Color(0xFF2E9E5B);
}

/// Locale tiếng Nhật để Kanji hiển thị đúng nét kiểu Nhật (không phải kiểu Trung).
const kJapanese = Locale('ja', 'JP');

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.vermilion,
    brightness: brightness,
  );
  final isLight = brightness == Brightness.light;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: isLight ? AppColors.paper : AppColors.night,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: isLight ? AppColors.paper : AppColors.night,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
