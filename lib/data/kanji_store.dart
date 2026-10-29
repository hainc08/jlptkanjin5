import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'kanji.dart';

/// Bộ Kanji của app: dữ liệu đóng sẵn + bản mới tải từ repo jlpt-content (GitHub Pages).
///
/// Trên server: `<baseUrl><app>.json`, ví dụ `kanji/n5.json`:
/// `{"schema": 1, "level": "N5", "kanji": [{"char": "一", "hanViet": "NHẤT", "meaning": "một", "on": "イチ", "kun": "ひと(つ)"}, ...]}`
/// Sửa file đó trên GitHub là app tự cập nhật, không cần build lại.
class KanjiStore extends ChangeNotifier {
  KanjiStore({
    required this.app,
    required this.bundled,
    SharedPreferences? prefs,
    http.Client? client,
    String? baseUrl,
  })  : _prefs = prefs,
        _client = client ?? http.Client(),
        baseUrl = baseUrl ?? 'https://hainc08.github.io/jlpt-content/kanji/';

  /// Store đang dùng trong app (null trong test thuần → dùng dữ liệu đóng sẵn).
  static KanjiStore? current;

  static const supportedSchema = 1;
  static const autoSyncInterval = Duration(hours: 6);

  /// Số chữ tối thiểu để chấp nhận một bộ dữ liệu tải về (tránh file hỏng/trống).
  static const minCount = 20;

  final String app;
  final List<Kanji> bundled;
  final String baseUrl;
  SharedPreferences? _prefs;
  final http.Client _client;

  List<Kanji>? _remote;
  bool syncing = false;

  String get _kSrc => 'kanji_remote_src_$app';
  String get _kEtag => 'kanji_remote_etag_$app';
  String get _kLastSync => 'kanji_remote_sync_$app';

  /// Danh sách đang dùng: bản tải về (nếu hợp lệ) hoặc bản đóng sẵn.
  List<Kanji> get items => _remote ?? bundled;

  bool get usingRemote => _remote != null;

  DateTime? get lastSync {
    final ms = _prefs?.getInt(_kLastSync);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final src = _prefs!.getString(_kSrc);
    if (src != null) _remote = parse(src);
  }

  /// Đọc và kiểm tra dữ liệu; trả về null nếu không hợp lệ.
  static List<Kanji>? parse(String src) {
    try {
      final j = jsonDecode(src) as Map<String, dynamic>;
      if (((j['schema'] as int?) ?? 1) > supportedSchema) return null;
      final list = <Kanji>[];
      for (final e in j['kanji'] as List) {
        final m = e as Map<String, dynamic>;
        list.add(Kanji(
          (m['char'] as String).trim(),
          (m['hanViet'] as String).trim(),
          (m['meaning'] as String).trim(),
          ((m['on'] as String?) ?? '').trim(),
          ((m['kun'] as String?) ?? '').trim(),
        ));
      }
      if (list.length < minCount) return null;
      // Quiz cần chữ và nghĩa không trùng để tạo 4 đáp án khác nhau.
      if (list.map((k) => k.char).toSet().length != list.length) return null;
      if (list.map((k) => k.meaning).toSet().length != list.length) return null;
      if (list.any((k) => k.char.isEmpty || k.hanViet.isEmpty || k.meaning.isEmpty || k.readingLabel.isEmpty)) {
        return null;
      }
      return list;
    } catch (_) {
      return null;
    }
  }

  Future<void> maybeSync() async {
    final last = lastSync;
    if (last != null && DateTime.now().difference(last) < autoSyncInterval) return;
    await sync();
  }

  /// 1 = có dữ liệu mới, 0 = không đổi, -1 = lỗi mạng / file không hợp lệ.
  Future<int> sync() async {
    if (syncing) return 0;
    _prefs ??= await SharedPreferences.getInstance();
    final prefs = _prefs!;
    syncing = true;
    notifyListeners();
    try {
      final cached = prefs.getString(_kSrc);
      final etag = prefs.getString(_kEtag);
      final headers = <String, String>{
        // Trên web, header tuỳ chỉnh gây CORS preflight → để trình duyệt tự xử lý cache.
        if (!kIsWeb && etag != null && cached != null) 'If-None-Match': etag,
      };
      final url = kIsWeb ? '$baseUrl$app.json?t=${DateTime.now().millisecondsSinceEpoch}' : '$baseUrl$app.json';
      final res = await _client.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 15));
      await prefs.setInt(_kLastSync, DateTime.now().millisecondsSinceEpoch);
      if (res.statusCode == 304) return 0;
      if (res.statusCode != 200) return -1;
      final src = utf8.decode(res.bodyBytes);
      final list = parse(src);
      if (list == null) return -1;
      final newEtag = res.headers['etag'];
      if (newEtag != null) await prefs.setString(_kEtag, newEtag);
      if (_same(list, items)) {
        await prefs.setString(_kSrc, src);
        _remote = list;
        return 0;
      }
      await prefs.setString(_kSrc, src);
      _remote = list;
      return 1;
    } catch (_) {
      return -1;
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

  static bool _same(List<Kanji> a, List<Kanji> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final x = a[i], y = b[i];
      if (x.char != y.char || x.hanViet != y.hanViet || x.meaning != y.meaning || x.on != y.on || x.kun != y.kun) {
        return false;
      }
    }
    return true;
  }
}
