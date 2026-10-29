import 'dart:async';

import 'package:flutter/material.dart';

import 'app_config.dart';
import 'app_scope.dart';
import 'data/kanji_store.dart';
import 'data/levels.dart';
import 'models/app_settings.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load();
  final store = KanjiStore(app: AppConfig.id, bundled: bundledKanji);
  await store.init();
  KanjiStore.current = store;
  runApp(AppScope(settings: settings, child: const KanjiApp()));
  // Kiểm tra dữ liệu Kanji mới trên GitHub ở nền.
  unawaited(store.maybeSync());
}

class KanjiApp extends StatelessWidget {
  const KanjiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    return MaterialApp(
      title: AppConfig.name,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
