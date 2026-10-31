import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:kanji_n5_flashcard/data/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final n5 = JlptLevel.n5.bundled;
  late DateTime clock;
  late SharedPreferences prefs;

  Future<ProgressStore> make() => ProgressStore.load(prefs: prefs, now: () => clock);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    clock = DateTime(2026, 10, 1, 9);
  });

  test('đúng 3 lần liên tiếp → đã thuộc', () async {
    final p = await make();
    final c = n5[0].char;
    p.record(JlptLevel.n5, c, true);
    p.record(JlptLevel.n5, c, true);
    expect(p.isMastered(JlptLevel.n5, c), isFalse);
    p.record(JlptLevel.n5, c, true);
    expect(p.isMastered(JlptLevel.n5, c), isTrue);
  });

  test('sai một lần → mất đã thuộc, vào cần ôn', () async {
    final p = await make();
    final k = n5[0];
    for (var i = 0; i < 3; i++) {
      p.record(JlptLevel.n5, k.char, true);
    }
    p.record(JlptLevel.n5, k.char, false);
    expect(p.isMastered(JlptLevel.n5, k.char), isFalse);
    expect(p.needsReview(JlptLevel.n5, n5), contains(k));
  });

  test('tiến độ tách riêng theo cấp', () async {
    final p = await make();
    final c = n5[0].char;
    for (var i = 0; i < 3; i++) {
      p.record(JlptLevel.n5, c, true);
    }
    expect(p.isMastered(JlptLevel.n4, c), isFalse);
  });

  test('percent chỉ tính chữ đang có trong cấp', () async {
    final p = await make();
    for (final k in [n5[0], n5[1]]) {
      for (var i = 0; i < 3; i++) {
        p.record(JlptLevel.n5, k.char, true);
      }
    }
    final items = [n5[0], n5[2], n5[3], n5[4]]; // n5[1] đã bị bỏ khỏi bộ dữ liệu
    expect(p.masteredCount(JlptLevel.n5, items), 1);
    expect(p.percent(JlptLevel.n5, items), 0.25);
    expect(p.percent(JlptLevel.n5, const []), 0);
  });

  test('needsReview bỏ chữ không còn trong cấp, sắp theo lần sai gần nhất', () async {
    final p = await make();
    p.record(JlptLevel.n5, n5[0].char, false);
    clock = clock.add(const Duration(hours: 1));
    p.record(JlptLevel.n5, n5[1].char, false);
    clock = clock.add(const Duration(hours: 1));
    p.record(JlptLevel.n5, n5[2].char, false);
    expect(p.needsReview(JlptLevel.n5, [n5[0], n5[1]]), [n5[1], n5[0]]);
  });

  test('todayCount đếm chữ khác nhau, reset qua ngày', () async {
    final p = await make();
    p.record(JlptLevel.n5, n5[0].char, true);
    p.record(JlptLevel.n5, n5[0].char, false);
    p.record(JlptLevel.n5, n5[1].char, true);
    expect(p.todayCount, 2);
    clock = DateTime(2026, 10, 2, 0, 1);
    expect(p.todayCount, 0);
  });

  test('streak: liên tiếp, hôm nay chưa học vẫn giữ, bỏ ngày thì về 0', () async {
    final p = await make();
    for (final d in [1, 2, 3]) {
      clock = DateTime(2026, 10, d, 20);
      p.record(JlptLevel.n5, n5[0].char, true);
    }
    expect(p.streakDays, 3);
    clock = DateTime(2026, 10, 4, 8);
    expect(p.streakDays, 3);
    clock = DateTime(2026, 10, 5, 8);
    expect(p.streakDays, 0);
  });

  test('streak: đồng hồ lùi không lỗi', () async {
    final p = await make();
    for (final d in [1, 2, 3]) {
      clock = DateTime(2026, 10, d, 20);
      p.record(JlptLevel.n5, n5[0].char, true);
    }
    clock = DateTime(2026, 10, 2, 8);
    expect(p.streakDays, greaterThanOrEqualTo(0));
  });

  test('JSON hỏng → coi như trống', () async {
    SharedPreferences.setMockInitialValues({
      'progress_n5': '{oops',
      'progress_days': 'x',
      'progress_today': '[',
    });
    prefs = await SharedPreferences.getInstance();
    final p = await make();
    expect(p.masteredCount(JlptLevel.n5, n5), 0);
    expect(p.todayCount, 0);
    expect(p.streakDays, 0);
  });

  test('lưu bền qua lần mở app sau', () async {
    final p = await make();
    for (var i = 0; i < 3; i++) {
      p.record(JlptLevel.n5, n5[0].char, true);
    }
    final again = await make();
    expect(again.isMastered(JlptLevel.n5, n5[0].char), isTrue);
    expect(again.todayCount, 1);
    expect(again.streakDays, 1);
  });

  test('clear xoá toàn bộ tiến độ', () async {
    final p = await make();
    p.record(JlptLevel.n4, JlptLevel.n4.bundled[0].char, false);
    await p.clear();
    expect(p.todayCount, 0);
    expect(p.streakDays, 0);
    expect(p.needsReview(JlptLevel.n4, JlptLevel.n4.bundled), isEmpty);
    expect(prefs.getKeys().where((k) => k.startsWith('progress_')), isEmpty);
  });

  test('đã học = từng trả lời đúng ít nhất 1 lần, sai sau đó vẫn tính', () async {
    final p = await make();
    p.record(JlptLevel.n5, n5[0].char, true);
    p.record(JlptLevel.n5, n5[0].char, false);
    p.record(JlptLevel.n5, n5[1].char, false); // chỉ sai → chưa tính đã học
    p.record(JlptLevel.n5, n5[2].char, true);
    expect(p.learnedCount(JlptLevel.n5, n5), 2);
    expect(p.learnedPercent(JlptLevel.n5, [n5[0], n5[1], n5[2], n5[3]]), 0.5);
    final again = await make();
    expect(again.learnedCount(JlptLevel.n5, n5), 2);
  });

  test('dữ liệu cũ (chưa có trường c) vẫn tính đã học theo chuỗi đúng', () async {
    SharedPreferences.setMockInitialValues({
      'progress_n5': '{"${n5[0].char}":{"s":2,"w":0,"lw":0},"${n5[1].char}":{"s":0,"w":1,"lw":5}}',
    });
    prefs = await SharedPreferences.getInstance();
    final p = await make();
    expect(p.learnedCount(JlptLevel.n5, n5), 1);
  });

  test('isLearning: đã gặp nhưng chưa thuộc', () async {
    final p = await make();
    p.record(JlptLevel.n5, n5[0].char, true);
    p.record(JlptLevel.n5, n5[1].char, false);
    for (var i = 0; i < 3; i++) {
      p.record(JlptLevel.n5, n5[2].char, true);
    }
    expect(p.isLearning(JlptLevel.n5, n5[0].char), isTrue);
    expect(p.isLearning(JlptLevel.n5, n5[1].char), isTrue);
    expect(p.isLearning(JlptLevel.n5, n5[2].char), isFalse);
    expect(p.isLearning(JlptLevel.n5, n5[3].char), isFalse);
  });
}
