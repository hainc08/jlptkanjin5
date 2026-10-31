import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:kanji_n5_flashcard/screens/levels_tab.dart';
import 'package:kanji_n5_flashcard/screens/test_screen.dart';
import 'package:kanji_n5_flashcard/widgets/level_card.dart';

import 'helpers.dart';

void main() {
  tearDown(resetPlatform);

  testWidgets('đủ 5 cấp, cấp đang học có nhãn Đang học', (tester) async {
    final app = await TestApp.create({'currentLevel': 'n4'});
    useScreen(tester, const Size(420, 1600));
    await tester.pumpWidget(app.wrap(const MaterialApp(home: Scaffold(body: LevelsTab()))));
    await tester.pump();
    expect(find.byType(LevelCard), findsNWidgets(5));
    final n4 = find.byWidgetPredicate((w) => w is LevelCard && w.level == JlptLevel.n4);
    expect(find.descendant(of: n4, matching: find.text('Đang học')), findsOneWidget);
    expect(find.text('Đang học'), findsOneWidget);
    resetPlatform();
  });

  testWidgets('bấm N2 khi đang học N4 → quiz N2, không đổi cấp đang học', (tester) async {
    final app = await TestApp.create({'currentLevel': 'n4'});
    useScreen(tester, const Size(420, 1600));
    await tester.pumpWidget(app.wrap(const MaterialApp(home: Scaffold(body: LevelsTab()))));
    await tester.pump();
    await tester.tap(find.byWidgetPredicate((w) => w is LevelCard && w.level == JlptLevel.n2));
    await tester.pumpAndSettle();
    expect(tester.widget<TestScreen>(find.byType(TestScreen)).level, JlptLevel.n2);
    expect(app.settings.currentLevel, JlptLevel.n4);
    resetPlatform();
  });
}
