import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:kanji_n5_flashcard/logic/quiz.dart';

void main() {
  final items = JlptLevel.n5.bundled.take(20).toList();
  bool Function(Kanji) masteredFirst(int n) {
    final set = items.take(n).map((k) => k.char).toSet();
    return (k) => set.contains(k.char);
  }

  test('ưu tiên chữ chưa thuộc, bù bằng chữ đã thuộc', () {
    final isMastered = masteredFirst(15);
    final r = pickTargets(items: items, isMastered: isMastered, count: 10);
    expect(r.length, 10);
    expect(r.where((k) => !isMastered(k)).length, 5);
  });

  test('đủ chữ chưa thuộc thì không lấy chữ đã thuộc', () {
    final isMastered = masteredFirst(5);
    final r = pickTargets(items: items, isMastered: isMastered, count: 10);
    expect(r.length, 10);
    expect(r.any(isMastered), isFalse);
  });

  test('count = 0 → hỏi hết', () {
    final r = pickTargets(items: items, isMastered: masteredFirst(3), count: 0);
    expect(r.length, items.length);
  });

  test('tất cả đã thuộc vẫn đủ câu', () {
    final r = pickTargets(items: items, isMastered: (_) => true, count: 10);
    expect(r.length, 10);
  });

  test('items ít hơn count', () {
    final r = pickTargets(items: items.take(4).toList(), isMastered: (_) => false, count: 10);
    expect(r.length, 4);
  });

  test('không trùng chữ', () {
    final r = pickTargets(items: items, isMastered: masteredFirst(15), count: 18);
    expect(r.map((k) => k.char).toSet().length, r.length);
  });

  group('ưu tiên chữ đang học', () {
    // 0..4 đã thuộc, 5..9 đang học, 10..19 chưa gặp.
    final mastered = items.take(5).map((k) => k.char).toSet();
    final learning = items.skip(5).take(5).map((k) => k.char).toSet();
    bool isM(Kanji k) => mastered.contains(k.char);
    bool isL(Kanji k) => learning.contains(k.char);

    test('chữ đang học được hỏi lại trước, phần còn lại là chữ mới', () {
      for (var seed = 0; seed < 20; seed++) {
        final r = pickTargets(
            items: items, isMastered: isM, isLearning: isL, count: 10, random: Random(seed));
        expect(r.where(isL).length, 5);
        expect(r.where((k) => !isL(k) && !isM(k)).length, 5);
      }
    });

    test('quá nhiều chữ đang học vẫn chừa chỗ cho chữ mới (tối đa 70%)', () {
      bool many(Kanji k) => !isM(k) && items.indexOf(k) < 15; // 10 đang học, 5 chữ mới
      final r = pickTargets(
          items: items, isMastered: isM, isLearning: many, count: 10, random: Random(1));
      expect(r.where(many).length, 7);
      expect(r.where((k) => !many(k) && !isM(k)).length, 3);
      expect(r.length, 10);
    });

    test('hết chữ mới thì bù bằng chữ đang học còn lại', () {
      bool all(Kanji k) => !isM(k); // 15 chữ đang học, 0 chữ mới
      final r = pickTargets(
          items: items, isMastered: isM, isLearning: all, count: 10, random: Random(2));
      expect(r.length, 10);
      expect(r.every(all), isTrue);
    });
  });
}
