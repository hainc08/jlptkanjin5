import 'jlpt_level.dart';
import 'kanji.dart';
import 'level_data.dart';

export 'jlpt_level.dart';
export 'kanji.dart';

/// Bộ Kanji đang dùng của một cấp: bản mới nhất tải từ GitHub (nếu có) hoặc bản đóng sẵn.
List<Kanji> kanjiOf(JlptLevel level) => LevelData.current?.kanjiOf(level) ?? level.bundled;
