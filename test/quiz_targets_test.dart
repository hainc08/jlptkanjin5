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
}
