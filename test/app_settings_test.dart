import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:kanji_n5_flashcard/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('chưa chọn cấp → null', () async {
    SharedPreferences.setMockInitialValues({});
    expect((await AppSettings.load()).currentLevel, isNull);
  });

  test('lưu cấp đang học, gán null thì xoá khoá', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await AppSettings.load();
    s.currentLevel = JlptLevel.n3;
    expect((await AppSettings.load()).currentLevel, JlptLevel.n3);
    s.currentLevel = null;
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('currentLevel'), isFalse);
  });

  test('giá trị rác → null', () async {
    SharedPreferences.setMockInitialValues({'currentLevel': 'zz'});
    expect((await AppSettings.load()).currentLevel, isNull);
  });

  test('giữ cài đặt cũ của bản 1.0.x', () async {
    SharedPreferences.setMockInitialValues({
      'questionCount': 20,
      'mode': 2,
      'darkMode': true,
      'showHanViet': false,
      'autoNext': true,
    });
    final s = await AppSettings.load();
    expect(s.questionCount, 20);
    expect(s.mode, QuizMode.meaningToKanji);
    expect(s.darkMode, isTrue);
    expect(s.showHanViet, isFalse);
    expect(s.autoNext, isTrue);
    expect(s.currentLevel, isNull);
  });
}
