import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'jlpt_level.dart';
import 'kanji.dart';

/// Tiến độ của một chữ trong một cấp.
class _Entry {
  _Entry({this.streak = 0, this.wrong = 0, this.lastWrong = 0, this.correct = 0});

  /// Số lần đúng liên tiếp.
  int streak;

  /// Tổng số lần sai.
  int wrong;

  /// Thời điểm sai gần nhất (ms).
  int lastWrong;

  /// Tổng số lần đúng (dữ liệu cũ chưa có thì lấy bằng [streak]).
  int correct;

  factory _Entry.fromJson(Map<String, dynamic> j) => _Entry(
        streak: (j['s'] as num?)?.toInt() ?? 0,
        wrong: (j['w'] as num?)?.toInt() ?? 0,
        lastWrong: (j['lw'] as num?)?.toInt() ?? 0,
        correct: (j['c'] as num?)?.toInt() ?? (j['s'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {'s': streak, 'w': wrong, 'lw': lastWrong, 'c': correct};
}

/// Tiến độ học, chỉ lưu trên máy bằng SharedPreferences.
///
/// - `progress_<cấp>`: `{chữ: {"s": đúng liên tiếp, "w": số lần sai, "lw": lần sai gần nhất, "c": tổng lần đúng}}`
/// - `progress_days`: các ngày có học (`yyyy-MM-dd`), dùng tính chuỗi ngày.
/// - `progress_today`: `{"d": ngày, "c": ["<cấp>:<chữ>", ...]}`, dùng đếm "Hôm nay".
class ProgressStore extends ChangeNotifier {
  ProgressStore._(this._prefs, this._now) {
    for (final l in JlptLevel.values) {
      _levels[l] = _readLevel(l);
    }
    _days = _readDays();
    _readToday();
  }

  static Future<ProgressStore> load({SharedPreferences? prefs, DateTime Function()? now}) async =>
      ProgressStore._(prefs ?? await SharedPreferences.getInstance(), now ?? DateTime.now);

  /// Đúng bấy nhiêu lần liên tiếp thì coi là đã thuộc.
  static const masteryStreak = 3;

  /// Cấp đang học đạt tỉ lệ này thì gợi ý sang cấp kế tiếp.
  static const nextLevelThreshold = 0.8;

  static const _kDays = 'progress_days';
  static const _kToday = 'progress_today';
  static const _maxDays = 400;

  final SharedPreferences _prefs;
  final DateTime Function() _now;
  final Map<JlptLevel, Map<String, _Entry>> _levels = {};
  late List<String> _days;
  String _todayDate = '';
  Set<String> _todayChars = {};

  static String _kLevel(JlptLevel l) => 'progress_${l.id}';

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, _Entry> _readLevel(JlptLevel l) {
    try {
      final j = jsonDecode(_prefs.getString(_kLevel(l)) ?? '{}') as Map<String, dynamic>;
      return {for (final e in j.entries) e.key: _Entry.fromJson(e.value as Map<String, dynamic>)};
    } catch (_) {
      return {};
    }
  }

  List<String> _readDays() {
    try {
      return [for (final d in jsonDecode(_prefs.getString(_kDays) ?? '[]') as List) d as String];
    } catch (_) {
      return [];
    }
  }

  void _readToday() {
    try {
      final j = jsonDecode(_prefs.getString(_kToday) ?? '{}') as Map<String, dynamic>;
      _todayDate = (j['d'] as String?) ?? '';
      _todayChars = {for (final c in (j['c'] as List?) ?? const []) c as String};
    } catch (_) {
      _todayDate = '';
      _todayChars = {};
    }
  }

  /// Ghi kết quả một câu trả lời.
  void record(JlptLevel level, String char, bool correct) {
    final now = _now();
    final entries = _levels[level]!;
    final e = entries.putIfAbsent(char, _Entry.new);
    if (correct) {
      e.streak++;
      e.correct++;
    } else {
      e.streak = 0;
      e.wrong++;
      e.lastWrong = now.millisecondsSinceEpoch;
    }
    _prefs.setString(_kLevel(level), jsonEncode(entries.map((k, v) => MapEntry(k, v.toJson()))));

    final today = _date(now);
    if (!_days.contains(today)) {
      _days = [..._days, today]..sort();
      if (_days.length > _maxDays) _days = _days.sublist(_days.length - _maxDays);
      _prefs.setString(_kDays, jsonEncode(_days));
    }
    if (_todayDate != today) {
      _todayDate = today;
      _todayChars = {};
    }
    _todayChars.add('${level.id}:$char');
    _prefs.setString(_kToday, jsonEncode({'d': _todayDate, 'c': _todayChars.toList()}));
    notifyListeners();
  }

  bool isMastered(JlptLevel level, String char) =>
      (_levels[level]![char]?.streak ?? 0) >= masteryStreak;

  /// Số chữ đã thuộc, chỉ tính các chữ đang có trong [items].
  int masteredCount(JlptLevel level, List<Kanji> items) =>
      items.where((k) => isMastered(level, k.char)).length;

  double percent(JlptLevel level, List<Kanji> items) =>
      items.isEmpty ? 0 : masteredCount(level, items) / items.length;

  /// Đã học = từng trả lời đúng ít nhất một lần.
  bool isLearned(JlptLevel level, String char) => (_levels[level]![char]?.correct ?? 0) > 0;

  /// Đang học = đã gặp (đúng hoặc sai) nhưng chưa thuộc.
  bool isLearning(JlptLevel level, String char) =>
      _levels[level]!.containsKey(char) && !isMastered(level, char);

  /// Số chữ đã học, chỉ tính các chữ đang có trong [items].
  int learnedCount(JlptLevel level, List<Kanji> items) =>
      items.where((k) => isLearned(level, k.char)).length;

  double learnedPercent(JlptLevel level, List<Kanji> items) =>
      items.isEmpty ? 0 : learnedCount(level, items) / items.length;

  /// Chữ từng sai và chưa thuộc, lần sai gần nhất đứng trước.
  List<Kanji> needsReview(JlptLevel level, List<Kanji> items) {
    final entries = _levels[level]!;
    final list = items.where((k) {
      final e = entries[k.char];
      return e != null && e.wrong > 0 && e.streak < masteryStreak;
    }).toList();
    list.sort((a, b) => entries[b.char]!.lastWrong.compareTo(entries[a.char]!.lastWrong));
    return list;
  }

  /// Số chữ khác nhau đã trả lời hôm nay (gộp mọi cấp).
  int get todayCount => _todayDate == _date(_now()) ? _todayChars.length : 0;

  /// Số ngày học liên tiếp, tính tới hôm nay (hoặc hôm qua nếu hôm nay chưa học).
  int get streakDays {
    final days = _days.toSet();
    final now = _now();
    var day = DateTime(now.year, now.month, now.day);
    if (!days.contains(_date(day))) day = DateTime(day.year, day.month, day.day - 1);
    var count = 0;
    while (days.contains(_date(day))) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }

  /// Xoá toàn bộ tiến độ của 5 cấp.
  Future<void> clear() async {
    for (final l in JlptLevel.values) {
      _levels[l] = {};
      await _prefs.remove(_kLevel(l));
    }
    _days = [];
    _todayDate = '';
    _todayChars = {};
    await _prefs.remove(_kDays);
    await _prefs.remove(_kToday);
    notifyListeners();
  }
}
