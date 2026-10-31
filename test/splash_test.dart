import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/screens/splash_screen.dart';

import 'helpers.dart';

void main() {
  tearDown(resetPlatform);

  testWidgets('Splash: logo và tên app nằm giữa màn hình', (tester) async {
    final app = await TestApp.create({'currentLevel': 'n5'});
    const phone = Size(393, 852);
    useScreen(tester, phone);
    await tester.pumpWidget(app.wrap(const MaterialApp(home: SplashScreen())));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getCenter(find.text('Kanji JLPT')).dx, closeTo(phone.width / 2, 1));
    expect(tester.getCenter(find.text('Flashcard N5 – N1')).dx, closeTo(phone.width / 2, 1));
    // Cho splash chuyển màn xong để không còn timer treo.
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
    resetPlatform();
  });
}
