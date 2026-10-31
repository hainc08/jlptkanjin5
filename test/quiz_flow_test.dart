import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:kanji_n5_flashcard/screens/test_screen.dart';

import 'helpers.dart';

/// Chữ Kanji đang được hỏi (chế độ mặc định Kanji → Nghĩa nên chữ hiện trên thẻ).
Kanji shownKanji(WidgetTester tester, JlptLevel level) =>
    kanjiOf(level).firstWhere((k) => tester.any(find.text(k.char)));

/// Bấm một đáp án sai (nghĩa của chữ khác trong cùng cấp đang hiện trên màn).
Future<void> tapWrong(WidgetTester tester, JlptLevel level, Kanji asked) async {
  final wrong = kanjiOf(level).firstWhere((k) => k != asked && tester.any(find.text(k.meaning)));
  await tester.tap(find.text(wrong.meaning));
  await tester.pump();
}

void main() {
  tearDown(resetPlatform);

  testWidgets('trả lời → ghi tiến độ vào đúng cấp', (tester) async {
    final app = await TestApp.create({'currentLevel': 'n5'});
    await tester.pumpWidget(app.wrap(const MaterialApp(home: TestScreen(level: JlptLevel.n3))));
    await tester.pump();
    final asked = shownKanji(tester, JlptLevel.n3);
    await tapWrong(tester, JlptLevel.n3, asked);
    expect(app.progress.needsReview(JlptLevel.n3, kanjiOf(JlptLevel.n3)), [asked]);
    expect(app.progress.needsReview(JlptLevel.n5, kanjiOf(JlptLevel.n5)), isEmpty);
    expect(app.progress.todayCount, 1);
    expect(find.textContaining('N3'), findsWidgets);
    resetPlatform();
  });

  testWidgets('Ôn câu sai cũng ghi tiến độ', (tester) async {
    final app = await TestApp.create({'currentLevel': 'n4'});
    final k = kanjiOf(JlptLevel.n4)[5];
    await tester.pumpWidget(app.wrap(MaterialApp(home: TestScreen(level: JlptLevel.n4, targets: [k]))));
    await tester.pump();
    await tapWrong(tester, JlptLevel.n4, k);
    expect(app.progress.needsReview(JlptLevel.n4, kanjiOf(JlptLevel.n4)), [k]);
    resetPlatform();
  });

  testWidgets('trả lời đúng không vào danh sách cần ôn', (tester) async {
    final app = await TestApp.create({'currentLevel': 'n4'});
    final k = kanjiOf(JlptLevel.n4)[7];
    await tester.pumpWidget(app.wrap(MaterialApp(home: TestScreen(level: JlptLevel.n4, targets: [k]))));
    await tester.pump();
    await tester.tap(find.text(k.meaning));
    await tester.pump();
    expect(app.progress.needsReview(JlptLevel.n4, kanjiOf(JlptLevel.n4)), isEmpty);
    expect(app.progress.todayCount, 1);
    resetPlatform();
  });
}
