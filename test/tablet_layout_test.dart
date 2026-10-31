import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:kanji_n5_flashcard/screens/home_tab.dart';
import 'package:kanji_n5_flashcard/screens/levels_tab.dart';
import 'package:kanji_n5_flashcard/screens/settings_screen.dart';
import 'package:kanji_n5_flashcard/screens/test_screen.dart';
import 'package:kanji_n5_flashcard/screens/welcome_screen.dart';
import 'package:kanji_n5_flashcard/widgets/flip_card.dart';
import 'package:kanji_n5_flashcard/widgets/level_card.dart';

import 'helpers.dart';

/// Màn hình iPad 13" (khổ dọc, đơn vị logic).
const ipad = Size(1032, 1376);

/// Bề rộng tối đa của cột nội dung trên màn rộng.
const maxContent = 640.0;

/// Giả lập màn iPad (cả kích thước vẽ lẫn MediaQuery).
void useIpad(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = ipad;
  addTearDown(tester.view.reset);
}

void main() {
  tearDown(resetPlatform);

  Future<TestApp> pump(WidgetTester tester, Widget screen, {Map<String, Object> prefs = const {'currentLevel': 'n4'}}) async {
    final app = await TestApp.create(prefs);
    useIpad(tester);
    await tester.pumpWidget(app.wrap(MaterialApp(home: screen)));
    await tester.pump();
    return app;
  }

  testWidgets('Chào hỏi: thẻ cấp không kéo giãn hết màn iPad', (tester) async {
    await pump(tester, const WelcomeScreen(), prefs: const {});
    expect(tester.getSize(find.byType(LevelCard).first).width, lessThanOrEqualTo(maxContent));
    resetPlatform();
  });

  testWidgets('Các cấp: thẻ cấp nằm trong cột giữa', (tester) async {
    await pump(tester, const Scaffold(body: LevelsTab()));
    final r = tester.getRect(find.byType(LevelCard).first);
    expect(r.width, lessThanOrEqualTo(maxContent));
    expect(r.center.dx, closeTo(ipad.width / 2, 1));
    resetPlatform();
  });

  testWidgets('Trang chủ: cột giữa, ô Cần ôn lại không quá to', (tester) async {
    final app = await TestApp.create({'currentLevel': 'n4'});
    for (final k in kanjiOf(JlptLevel.n4).take(4)) {
      app.progress.record(JlptLevel.n4, k.char, false);
    }
    useIpad(tester);
    await tester.pumpWidget(app.wrap(const MaterialApp(home: Scaffold(body: HomeTab()))));
    await tester.pump();
    final tiles = find.byKey(const ValueKey('review-tile'));
    expect(tiles, findsNWidgets(4));
    final first = tester.getRect(tiles.first);
    expect(first.height, lessThanOrEqualTo(200));
    // 4 ô trên một hàng khi đủ rộng.
    expect(tester.getRect(tiles.at(3)).top, first.top);
    expect(tester.getSize(find.text('Tiếp tục học')).width, lessThan(maxContent));
    resetPlatform();
  });

  testWidgets('Quiz: thẻ lật không kéo giãn hết màn iPad', (tester) async {
    await pump(tester, const TestScreen(level: JlptLevel.n4));
    expect(tester.getSize(find.byType(FlipCard)).width, lessThanOrEqualTo(maxContent));
    resetPlatform();
  });

  testWidgets('Cài đặt: nội dung nằm trong cột giữa', (tester) async {
    await pump(tester, const SettingsScreen());
    final tile = find.ancestor(of: find.text('Cấp đang học'), matching: find.byType(ListTile));
    expect(tester.getSize(tile).width, lessThanOrEqualTo(maxContent));
    resetPlatform();
  });
}
