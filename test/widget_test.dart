import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/data/kanji_n5.dart';
import 'package:kanji_n5_flashcard/logic/quiz.dart';
import 'package:kanji_n5_flashcard/models/app_settings.dart';

void main() {
  test('Dữ liệu không trùng chữ Kanji', () {
    expect(kanjiN5.map((k) => k.char).toSet().length, kanjiN5.length);
  });

  test('buildQuiz tạo đủ câu, mỗi câu 4 đáp án khác nhau', () {
    for (final mode in QuizMode.values) {
      final quiz = buildQuiz(
        targets: kanjiN5,
        all: kanjiN5,
        mode: mode,
        count: 10,
      );
      expect(quiz.length, 10);
      for (final q in quiz) {
        expect(q.options.length, 4);
        expect(q.options.toSet().length, 4);
        expect(q.options[q.correctIndex], answerOf(q.kanji, mode));
      }
    }
  });

  test('Ôn câu sai: hỏi hết các chữ được truyền vào', () {
    final targets = kanjiN5.take(3).toList();
    final quiz = buildQuiz(
      targets: targets,
      all: kanjiN5,
      mode: QuizMode.kanjiToMeaning,
      count: 0,
    );
    expect(quiz.length, 3);
    expect(quiz.every((q) => q.options.length == 4), isTrue);
  });
}
