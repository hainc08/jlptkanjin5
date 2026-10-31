import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:kanji_n5_flashcard/screens/home_tab.dart';
import 'package:kanji_n5_flashcard/screens/test_screen.dart';

import 'helpers.dart';

void main() {
  tearDown(resetPlatform);

  Future<TestApp> pumpHome(WidgetTester tester, String level, [void Function(TestApp)? seed]) async {
    final app = await TestApp.create({'currentLevel': level});
    seed?.call(app);
    useScreen(tester, const Size(420, 2000));
    await tester.pumpWidget(app.wrap(const MaterialApp(home: Scaffold(body: HomeTab()))));
    await tester.pump();
    return app;
  }

  void master(TestApp app, JlptLevel l, int n) {
    for (final k in kanjiOf(l).take(n)) {
      for (var i = 0; i < 3; i++) {
        app.progress.record(l, k.char, true);
      }
    }
  }

  testWidgets('người mới: 0%, không có Cần ôn lại, không gợi ý', (tester) async {
    await pumpHome(tester, 'n5');
    expect(find.text('Tiếp tục học'), findsOneWidget);
    expect(find.textContaining('0/104'), findsOneWidget);
    expect(find.text('Cần ôn lại'), findsNothing);
    expect(find.textContaining('gần xong'), findsNothing);
    resetPlatform();
  });

  testWidgets('có chữ sai → Cần ôn lại tối đa 4 ô', (tester) async {
    await pumpHome(tester, 'n5', (app) {
      for (final k in kanjiOf(JlptLevel.n5).take(6)) {
        app.progress.record(JlptLevel.n5, k.char, false);
      }
    });
    expect(find.text('Cần ôn lại'), findsOneWidget);
    expect(find.byKey(const ValueKey('review-tile')), findsNWidgets(4));
    expect(find.text('Ôn các chữ này'), findsOneWidget);
    resetPlatform();
  });

  testWidgets('≥ 80% → gợi ý cấp kế, bấm thì đổi cấp', (tester) async {
    late TestApp app;
    app = await pumpHome(tester, 'n5', (a) => master(a, JlptLevel.n5, 84));
    expect(find.textContaining('gần xong'), findsOneWidget);
    await tester.tap(find.textContaining('gần xong'));
    await tester.pump();
    expect(app.settings.currentLevel, JlptLevel.n4);
    resetPlatform();
  });

  testWidgets('N1 ≥ 80% → không gợi ý', (tester) async {
    await pumpHome(tester, 'n1', (a) => master(a, JlptLevel.n1, 220));
    expect(find.textContaining('gần xong'), findsNothing);
    resetPlatform();
  });

  testWidgets('Học tiếp mở quiz của cấp đang học', (tester) async {
    await pumpHome(tester, 'n3');
    await tester.tap(find.text('Học tiếp'));
    await tester.pumpAndSettle();
    expect(tester.widget<TestScreen>(find.byType(TestScreen)).level, JlptLevel.n3);
    resetPlatform();
  });

  testWidgets('trả lời đúng 1 lần → thẻ Tiếp tục học hiện Đã học 1', (tester) async {
    await pumpHome(tester, 'n5', (app) {
      app.progress.record(JlptLevel.n5, kanjiOf(JlptLevel.n5)[0].char, true);
    });
    expect(find.textContaining('Đã học 1'), findsOneWidget);
    expect(find.textContaining('Đã thuộc 0'), findsOneWidget);
    resetPlatform();
  });
}
