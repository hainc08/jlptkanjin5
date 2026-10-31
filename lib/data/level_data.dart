import 'kanji.dart';
import 'kanji_store.dart';
import 'jlpt_level.dart';

/// Dữ liệu Kanji của cả 5 cấp: mỗi cấp một [KanjiStore] (đóng sẵn + bản mới tải từ GitHub).
class LevelData {
  LevelData({Map<JlptLevel, KanjiStore>? stores})
      : _stores = stores ??
            {for (final l in JlptLevel.values) l: KanjiStore(app: l.id, bundled: l.bundled)};

  /// Dữ liệu đang dùng trong app (null trong test thuần → dùng dữ liệu đóng sẵn).
  static LevelData? current;

  final Map<JlptLevel, KanjiStore> _stores;

  KanjiStore storeOf(JlptLevel l) => _stores[l]!;

  List<Kanji> kanjiOf(JlptLevel l) => storeOf(l).items;

  Future<void> init() => Future.wait(_stores.values.map((s) => s.init()));

  Future<void> maybeSyncAll() => Future.wait(_stores.values.map((s) => s.maybeSync()));

  /// 1 = có cấp có dữ liệu mới, -1 = mọi cấp đều lỗi, 0 = không đổi.
  Future<int> syncAll() async {
    final results = await Future.wait(_stores.values.map((s) => s.sync()));
    if (results.contains(1)) return 1;
    if (results.every((r) => r == -1)) return -1;
    return 0;
  }
}
