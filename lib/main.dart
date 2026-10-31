import 'dart:async';

import 'package:flutter/material.dart';

import 'app_config.dart';
import 'app_scope.dart';
import 'data/jlpt_level.dart';
import 'data/level_data.dart';
import 'data/progress_store.dart';
import 'models/app_settings.dart';
import 'progress_scope.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load();
  final progress = await ProgressStore.load();
  final data = LevelData();
  await data.init();
  LevelData.current = data;
  runApp(ProgressScope(
    progress: progress,
    child: AppScope(settings: settings, child: const KanjiApp()),
  ));
  // Kiểm tra dữ liệu Kanji mới của 5 cấp trên GitHub ở nền.
  unawaited(data.maybeSyncAll());
}

class KanjiApp extends StatelessWidget {
  const KanjiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final accent = (settings.currentLevel ?? JlptLevel.n5).color;
    return MaterialApp(
      title: AppConfig.name,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light, accent: accent),
      darkTheme: buildTheme(Brightness.dark, accent: accent),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
