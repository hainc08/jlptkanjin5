import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';

void main() {
  test('bộ chữ đóng sẵn đủ 5 cấp, chữ và nghĩa không trùng trong từng cấp', () {
    expect({for (final l in JlptLevel.values) l.id: kanjiOf(l).length},
        {'n5': 110, 'n4': 182, 'n3': 282, 'n2': 234, 'n1': 264});
    final all = [for (final l in JlptLevel.values) ...kanjiOf(l).map((k) => k.char)];
    expect(all.toSet().length, all.length, reason: 'không chữ nào lặp giữa các cấp');
    for (final l in JlptLevel.values) {
      final items = kanjiOf(l);
      expect(items.map((k) => k.meaning).toSet().length, items.length, reason: l.id);
      expect(items.where((k) => k.hanViet.isEmpty || k.meaning.isEmpty || k.readingLabel.isEmpty), isEmpty);
    }
  });
}
