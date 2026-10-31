import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:kanji_n5_flashcard/theme.dart';

void main() {
  test('nền giấy kem, font Be Vietnam Pro + Noto Serif', () {
    final t = buildTheme(Brightness.light, accent: JlptLevel.n4.color);
    expect(t.scaffoldBackgroundColor, const Color(0xFFFBF9F4));
    expect(t.textTheme.bodyMedium!.fontFamily, 'BeVietnamPro');
    expect(t.textTheme.headlineSmall!.fontFamily, 'NotoSerif');
  });

  test('màu nhấn theo cấp', () {
    final a = buildTheme(Brightness.light, accent: JlptLevel.n5.color).colorScheme.primary;
    final b = buildTheme(Brightness.light, accent: JlptLevel.n1.color).colorScheme.primary;
    expect(a, isNot(b));
  });

  test('chế độ tối', () {
    final t = buildTheme(Brightness.dark, accent: JlptLevel.n3.color);
    expect(t.brightness, Brightness.dark);
    expect(t.scaffoldBackgroundColor, AppColors.night);
  });

  test('kanjiStyle dùng locale tiếng Nhật', () {
    expect(kanjiStyle(40).locale, kJapanese);
    expect(kanjiStyle(40).fontSize, 40);
  });
}
