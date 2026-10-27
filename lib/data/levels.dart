import '../app_config.dart';
import 'kanji.dart';
import 'kanji_n4.dart';
import 'kanji_n5.dart';

export 'kanji.dart';

/// Bộ Kanji của app đang build. Thêm app mới: tạo file dữ liệu rồi thêm một dòng ở đây.
List<Kanji> get appKanji => switch (AppConfig.id) {
      'n4' => kanjiN4,
      _ => kanjiN5,
    };
