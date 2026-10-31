import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kanji_n5_flashcard/data/kanji_n1.dart';
import 'package:kanji_n5_flashcard/data/kanji_store.dart';
import 'package:kanji_n5_flashcard/data/level_data.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('5 cấp theo thứ tự N5..N1', () {
    expect(JlptLevel.values.map((l) => l.id), ['n5', 'n4', 'n3', 'n2', 'n1']);
    expect(JlptLevel.values.map((l) => l.label), ['N5', 'N4', 'N3', 'N2', 'N1']);
  });

  test('dữ liệu đóng sẵn, cấp kế tiếp, màu', () {
    expect(JlptLevel.n3.bundled.length, 276);
    expect(JlptLevel.n5.next, JlptLevel.n4);
    expect(JlptLevel.n2.next, JlptLevel.n1);
    expect(JlptLevel.n1.next, isNull);
    expect(JlptLevel.n5.color, const Color(0xFF2E7D32));
    expect(JlptLevel.n1.color, const Color(0xFFC62828));
    expect(JlptLevel.n3.description, 'Trung cấp');
  });

  test('fromId', () {
    expect(JlptLevel.fromId('n4'), JlptLevel.n4);
    expect(JlptLevel.fromId('x'), isNull);
    expect(JlptLevel.fromId(null), isNull);
  });

  test('LevelData: mỗi cấp một store, mất mạng dùng bản đóng sẵn', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final client = MockClient((_) async => http.Response('', 404));
    final data = LevelData(stores: {
      for (final l in JlptLevel.values)
        l: KanjiStore(app: l.id, bundled: l.bundled, prefs: prefs, client: client),
    });
    await data.init();
    expect(data.kanjiOf(JlptLevel.n1), kanjiN1);
    expect(data.storeOf(JlptLevel.n2).app, 'n2');
    expect(await data.syncAll(), -1);
  });
}
