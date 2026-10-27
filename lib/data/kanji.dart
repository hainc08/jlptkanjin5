/// Một chữ Kanji kèm Hán Việt, nghĩa tiếng Việt, âm On và âm Kun.
class Kanji {
  const Kanji(this.char, this.hanViet, this.meaning, this.on, this.kun);

  final String char;
  final String hanViet;
  final String meaning;
  final String on;
  final String kun;

  /// Chuỗi cách đọc dùng làm đáp án: "On / Kun".
  String get readingLabel =>
      [on, kun].where((e) => e.isNotEmpty).join(' / ');
}
