import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/app_config.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:kanji_n5_flashcard/screens/settings_screen.dart';

import 'helpers.dart';

void main() {
  tearDown(resetPlatform);

  Future<TestApp> pumpSettings(WidgetTester tester) async {
    final app = await TestApp.create({'currentLevel': 'n4'});
    app.progress.record(JlptLevel.n4, kanjiOf(JlptLevel.n4)[0].char, false);
    useScreen(tester, const Size(420, 2600));
    await tester.pumpWidget(app.wrap(const MaterialApp(home: SettingsScreen())));
    await tester.pump();
    return app;
  }

  testWidgets('đổi cấp đang học qua bottom sheet', (tester) async {
    final app = await pumpSettings(tester);
    await tester.tap(find.text('Cấp đang học'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pick-n1')));
    await tester.pumpAndSettle();
    expect(app.settings.currentLevel, JlptLevel.n1);
    resetPlatform();
  });

  testWidgets('Xoá lịch sử học → Huỷ thì giữ nguyên', (tester) async {
    final app = await pumpSettings(tester);
    await tester.tap(find.text('Xóa lịch sử học'));
    await tester.pumpAndSettle();
    expect(find.text('Toàn bộ tiến độ của 5 cấp sẽ bị xóa.'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(app.progress.todayCount, 1);
    expect(app.settings.currentLevel, JlptLevel.n4);
    resetPlatform();
  });

  testWidgets('Xoá lịch sử học → về màn Chào hỏi', (tester) async {
    final app = await pumpSettings(tester);
    await tester.tap(find.text('Xóa lịch sử học'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();
    expect(app.progress.todayCount, 0);
    expect(app.settings.currentLevel, isNull);
    expect(find.text('Chào bạn!'), findsOneWidget);
    resetPlatform();
  });

  testWidgets('hiện phiên bản thật và tổng số chữ 5 cấp', (tester) async {
    await pumpSettings(tester);
    expect(find.text('Kanji JLPT · Phiên bản ${AppConfig.version}'), findsOneWidget);
    final total = JlptLevel.values.fold<int>(0, (s, l) => s + kanjiOf(l).length);
    expect(find.textContaining('5 cấp · $total chữ Kanji'), findsOneWidget);
    resetPlatform();
  });
}
