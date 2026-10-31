import 'dart:ui';

import 'kanji_n1.dart';
import 'kanji_n2.dart';
import 'kanji_n3.dart';
import 'kanji_n4.dart';
import 'kanji_n5.dart';

/// 5 cấp JLPT trong app, theo thứ tự lộ trình N5 → N1.
enum JlptLevel {
  n5('N5', 'Mới bắt đầu', Color(0xFF2E7D32)),
  n4('N4', 'Cơ bản', Color(0xFF1565C0)),
  n3('N3', 'Trung cấp', Color(0xFF00897B)),
  n2('N2', 'Trung cao', Color(0xFFE65100)),
  n1('N1', 'Cao cấp', Color(0xFFC62828));

  const JlptLevel(this.label, this.description, this.color);

  final String label;
  final String description;
  final Color color;

  /// Mã dùng cho khoá lưu trữ và tên file dữ liệu trên GitHub (`kanji/<id>.json`).
  String get id => name;

  /// Bộ Kanji đóng sẵn trong app.
  List<Kanji> get bundled => switch (this) {
        JlptLevel.n5 => kanjiN5,
        JlptLevel.n4 => kanjiN4,
        JlptLevel.n3 => kanjiN3,
        JlptLevel.n2 => kanjiN2,
        JlptLevel.n1 => kanjiN1,
      };

  /// Cấp kế tiếp trên lộ trình; N1 là cấp cuối.
  JlptLevel? get next => index + 1 < values.length ? values[index + 1] : null;

  static JlptLevel? fromId(String? id) {
    for (final l in values) {
      if (l.id == id) return l;
    }
    return null;
  }
}
