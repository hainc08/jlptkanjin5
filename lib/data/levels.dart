import '../app_config.dart';
import 'kanji.dart';
import 'kanji_n1.dart';
import 'kanji_n2.dart';
import 'kanji_n3.dart';
import 'kanji_n4.dart';
import 'kanji_n5.dart';
import 'kanji_store.dart';

export 'kanji.dart';

/// Bộ Kanji đóng sẵn trong app đang build. Thêm app mới: tạo file dữ liệu rồi thêm một dòng ở đây.
List<Kanji> get bundledKanji => switch (AppConfig.id) {
      'n4' => kanjiN4,
      'n3' => kanjiN3,
      'n2' => kanjiN2,
      'n1' => kanjiN1,
      _ => kanjiN5,
    };

/// Bộ Kanji đang dùng: bản mới nhất tải từ GitHub (nếu có) hoặc bản đóng sẵn.
List<Kanji> get appKanji => KanjiStore.current?.items ?? bundledKanji;
