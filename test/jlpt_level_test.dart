import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';

void main() {
  test('5 cấp theo thứ tự N5..N1', () {
    expect(JlptLevel.values.map((l) => l.id), ['n5', 'n4', 'n3', 'n2', 'n1']);
    expect(JlptLevel.values.map((l) => l.label), ['N5', 'N4', 'N3', 'N2', 'N1']);
  });

  test('dữ liệu đóng sẵn, cấp kế tiếp, màu', () {
    expect(JlptLevel.n3.bundled.length, 282);
    expect(JlptLevel.n5.next, JlptLevel.n4);
    expect(JlptLevel.n2.next, JlptLevel.n1);
    expect(JlptLevel.n1.next, isNull);
    expect(JlptLevel.n5.color, const Color(0xFF2E7D32));
    expect(JlptLevel.n1.color, const Color(0xFFC62828));
    expect(JlptLevel.n3.description, 'Trung cấp');
  });

  test('fromId', () {
    expect(JlptLevel.fromId('n4'), JlptLevel.n4);
    expect(JlptLevel.fromId('x'), isNull);
    expect(JlptLevel.fromId(null), isNull);
  });
}
