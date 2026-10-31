import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/kanji_n1.dart';
import 'package:kanji_n5_flashcard/data/kanji_n2.dart';
import 'package:kanji_n5_flashcard/data/kanji_n3.dart';
import 'package:kanji_n5_flashcard/data/kanji_n4.dart';
import 'package:kanji_n5_flashcard/data/kanji_n5.dart';
import 'package:kanji_n5_flashcard/data/levels.dart';
import 'package:kanji_n5_flashcard/logic/quiz.dart';
import 'package:kanji_n5_flashcard/models/app_settings.dart';

void main() {
  final levels = {
    'N5': kanjiN5,
    'N4': kanjiN4,
    'N3': kanjiN3,
    'N2': kanjiN2,
    'N1': kanjiN1,
  };

  for (final MapEntry(key: level, value: data) in levels.entries) {
    group(level, () {
      test('Dữ liệu không trùng chữ Kanji, không trùng nghĩa', () {
        expect(data.map((k) => k.char).toSet().length, data.length);
        expect(data.map((k) => k.meaning).toSet().length, data.length);
        expect(data.every((k) => k.hanViet.isNotEmpty && k.on.isNotEmpty), isTrue);
      });

      test('buildQuiz tạo đủ câu, mỗi câu 4 đáp án khác nhau', () {
        for (final mode in QuizMode.values) {
          final quiz = buildQuiz(targets: data, all: data, mode: mode, count: 10);
          expect(quiz.length, 10);
          for (final q in quiz) {
            expect(q.options.length, 4);
            expect(q.options.toSet().length, 4);
            expect(q.options[q.correctIndex], answerOf(q.kanji, mode));
          }
        }
      });

      test('Ôn câu sai: hỏi hết các chữ được truyền vào', () {
        final targets = data.take(3).toList();
        final quiz = buildQuiz(
          targets: targets,
          all: data,
          mode: QuizMode.kanjiToMeaning,
          count: 0,
        );
        expect(quiz.length, 3);
        expect(quiz.every((q) => q.options.length == 4), isTrue);
      });
    });
  }

  test('Các cấp N5..N1 không lặp lại chữ của nhau', () {
    final seen = <String>{};
    for (final entry in levels.entries) {
      for (final k in entry.value) {
        expect(seen.add(k.char), isTrue, reason: 'Trùng chữ ${k.char} ở ${entry.key}');
      }
    }
  });

  test('kanjiOf trả dữ liệu cho cả 5 cấp', () {
    for (final l in JlptLevel.values) {
      expect(kanjiOf(l), isNotEmpty);
    }
  });
}
