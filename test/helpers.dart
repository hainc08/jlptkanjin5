import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:kanji_n5_flashcard/app_scope.dart';
import 'package:kanji_n5_flashcard/data/progress_store.dart';
import 'package:kanji_n5_flashcard/main.dart';
import 'package:kanji_n5_flashcard/models/app_settings.dart';
import 'package:kanji_n5_flashcard/progress_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Môi trường test của app: prefs giả, tắt AdMob (chỉ chạy trên Android/iOS).
class TestApp {
  TestApp._(this.settings, this.progress);

  final AppSettings settings;
  final ProgressStore progress;

  static Future<TestApp> create([Map<String, Object> prefs = const {}]) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    SharedPreferences.setMockInitialValues(prefs);
    return TestApp._(await AppSettings.load(), await ProgressStore.load());
  }

  /// Bọc [child] bằng các scope của app. Mặc định là toàn bộ app (bắt đầu từ Splash).
  Widget wrap([Widget? child]) => ProgressScope(
        progress: progress,
        child: AppScope(settings: settings, child: child ?? const KanjiApp()),
      );
}

void resetPlatform() => debugDefaultTargetPlatformOverride = null;
