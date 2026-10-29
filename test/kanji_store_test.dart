import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kanji_n5_flashcard/data/kanji_n5.dart';
import 'package:kanji_n5_flashcard/data/kanji_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

String toJson(List<Kanji> list) => jsonEncode({
      'schema': 1,
      'level': 'N5',
      'kanji': [
        for (final k in list) {'char': k.char, 'hanViet': k.hanViet, 'meaning': k.meaning, 'on': k.on, 'kun': k.kun}
      ],
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String body;
  late bool offline;
  late SharedPreferences prefs;

  http.Client client() => MockClient((req) async {
        if (offline) throw const SocketException('offline');
        final etag = '"${body.hashCode}"';
        if (req.headers['If-None-Match'] == etag) return http.Response('', 304);
        return http.Response.bytes(utf8.encode(body), 200, headers: {'etag': etag});
      });

  Future<KanjiStore> make() async {
    final s = KanjiStore(app: 'n5', bundled: kanjiN5, prefs: prefs, client: client(), baseUrl: 'https://example.test/kanji/');
    await s.init();
    return s;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    body = toJson(kanjiN5);
    offline = false;
  });

  test('chưa đồng bộ / mất mạng: dùng dữ liệu đóng sẵn', () async {
    offline = true;
    final s = await make();
    expect(await s.sync(), -1);
    expect(s.items, same(kanjiN5));
  });

  test('dữ liệu trên GitHub giống bản đóng sẵn → không đổi', () async {
    final s = await make();
    expect(await s.sync(), 0);
    expect(s.items.length, kanjiN5.length);
    expect(await s.sync(), 0); // lần 2: 304
  });

  test('thêm chữ + sửa nghĩa trên GitHub → app cập nhật, giữ được khi offline', () async {
    final edited = [
      ...kanjiN5.map((k) => k.char == '一' ? Kanji(k.char, k.hanViet, 'một (số 1)', k.on, k.kun) : k),
      const Kanji('森', 'SÂM', 'rừng rậm', 'シン', 'もり'),
    ];
    body = toJson(edited);
    final s = await make();
    expect(await s.sync(), 1);
    expect(s.items.length, kanjiN5.length + 1);
    expect(s.items.first.meaning, 'một (số 1)');

    offline = true;
    final again = await make();
    expect(again.items.length, kanjiN5.length + 1);
  });

  test('file hỏng / trùng nghĩa / quá ít chữ → bỏ qua, giữ bộ cũ', () async {
    final s = await make();
    for (final bad in [
      '{"kanji": [',
      toJson(kanjiN5.take(5).toList()),
      toJson([...kanjiN5, Kanji('毎', 'MỖI', kanjiN5.first.meaning, 'マイ', '')]),
    ]) {
      body = bad;
      expect(await s.sync(), -1);
      expect(s.items, same(kanjiN5));
    }
  });
}
