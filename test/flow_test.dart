import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';

import 'helpers.dart';

void main() {
  tearDown(resetPlatform);

  testWidgets('lần đầu: Splash → Chào hỏi → chọn N4 → Trang chủ', (tester) async {
    final app = await TestApp.create();
    await tester.pumpWidget(app.wrap());
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
    expect(find.text('Chào bạn!'), findsOneWidget);

    await tester.tap(find.text('N4'));
    await tester.pumpAndSettle();
    expect(app.settings.currentLevel, JlptLevel.n4);
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Trang chủ', 'Các cấp', 'Cài đặt']) {
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)), findsOneWidget);
    }
    resetPlatform();
  });

  testWidgets('lần sau: Splash → Trang chủ', (tester) async {
    final app = await TestApp.create({'currentLevel': 'n2'});
    await tester.pumpWidget(app.wrap());
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
    expect(find.text('Chào bạn!'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    resetPlatform();
  });
}
