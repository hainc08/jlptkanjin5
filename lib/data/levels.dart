import 'jlpt_level.dart';
import 'kanji.dart';

export 'jlpt_level.dart';
export 'kanji.dart';

/// Bộ Kanji của một cấp. Dữ liệu chỉ đóng sẵn trong app, không tải từ mạng:
/// mọi thay đổi đều đi qua một bản phát hành mới.
List<Kanji> kanjiOf(JlptLevel level) => level.bundled;
