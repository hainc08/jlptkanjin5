import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/jlpt_level.dart';

enum QuizMode { kanjiToMeaning, kanjiToReading, meaningToKanji }

extension QuizModeText on QuizMode {
  String get label => switch (this) {
        QuizMode.kanjiToMeaning => 'Kanji → Nghĩa',
        QuizMode.kanjiToReading => 'Kanji → Cách đọc',
        QuizMode.meaningToKanji => 'Nghĩa → Kanji',
      };

  String get description => switch (this) {
        QuizMode.kanjiToMeaning => 'Nhìn chữ Kanji, chọn nghĩa tiếng Việt',
        QuizMode.kanjiToReading => 'Nhìn chữ Kanji, chọn âm On / Kun',
        QuizMode.meaningToKanji => 'Nhìn nghĩa, chọn chữ Kanji đúng',
      };

  String get instruction => switch (this) {
        QuizMode.kanjiToMeaning => 'Chọn nghĩa đúng của chữ Kanji',
        QuizMode.kanjiToReading => 'Chọn cách đọc đúng',
        QuizMode.meaningToKanji => 'Chọn chữ Kanji đúng với nghĩa',
      };

  IconData get icon => switch (this) {
        QuizMode.kanjiToMeaning => Icons.translate,
        QuizMode.kanjiToReading => Icons.record_voice_over_outlined,
        QuizMode.meaningToKanji => Icons.draw_outlined,
      };
}

/// Cài đặt của app, lưu bằng SharedPreferences.
class AppSettings extends ChangeNotifier {
  AppSettings._(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppSettings> load() async =>
      AppSettings._(await SharedPreferences.getInstance());

  /// Các lựa chọn số câu; 0 = tất cả.
  static const questionCountOptions = [10, 20, 50, 0];

  int get questionCount => _prefs.getInt('questionCount') ?? 10;
  set questionCount(int value) {
    _prefs.setInt('questionCount', value);
    notifyListeners();
  }

  QuizMode get mode {
    final i = _prefs.getInt('mode') ?? 0;
    return QuizMode.values[i.clamp(0, QuizMode.values.length - 1)];
  }

  set mode(QuizMode value) {
    _prefs.setInt('mode', value.index);
    notifyListeners();
  }

  bool get darkMode => _prefs.getBool('darkMode') ?? false;
  set darkMode(bool value) {
    _prefs.setBool('darkMode', value);
    notifyListeners();
  }

  bool get showHanViet => _prefs.getBool('showHanViet') ?? true;
  set showHanViet(bool value) {
    _prefs.setBool('showHanViet', value);
    notifyListeners();
  }

  /// Cấp đang học; null = chưa qua màn Chào hỏi.
  JlptLevel? get currentLevel => JlptLevel.fromId(_prefs.getString('currentLevel'));
  set currentLevel(JlptLevel? value) {
    if (value == null) {
      _prefs.remove('currentLevel');
    } else {
      _prefs.setString('currentLevel', value.id);
    }
    notifyListeners();
  }

  bool get autoNext => _prefs.getBool('autoNext') ?? false;
  set autoNext(bool value) {
    _prefs.setBool('autoNext', value);
    notifyListeners();
  }
}
