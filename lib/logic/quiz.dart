import 'dart:math';

import '../data/kanji.dart';
import '../models/app_settings.dart';

class Question {
  Question({
    required this.kanji,
    required this.options,
    required this.correctIndex,
  });

  final Kanji kanji;
  final List<String> options;
  final int correctIndex;

  /// Vị trí đáp án người dùng chọn; null = chưa trả lời.
  int? chosen;

  bool get answered => chosen != null;
  bool get isCorrect => chosen == correctIndex;
}

/// Đáp án đúng của một chữ theo kiểu câu hỏi.
String answerOf(Kanji k, QuizMode mode) => switch (mode) {
      QuizMode.kanjiToMeaning => k.meaning,
      QuizMode.kanjiToReading => k.readingLabel,
      QuizMode.meaningToKanji => k.char,
    };

/// Chọn chữ để hỏi, theo thứ tự ưu tiên:
/// 1. chữ đang học dở ([isLearning]), tối đa 70% số câu để chữ sớm đạt "đã thuộc";
/// 2. chữ chưa gặp;
/// 3. chữ đang học còn lại; 4. chữ đã thuộc.
/// [count] <= 0 nghĩa là hỏi hết [items].
List<Kanji> pickTargets({
  required List<Kanji> items,
  required bool Function(Kanji) isMastered,
  bool Function(Kanji)? isLearning,
  required int count,
  Random? random,
}) {
  final rng = random ?? Random();
  final learningOf = isLearning ?? (_) => false;
  final known = items.where(isMastered).toList()..shuffle(rng);
  final learning = items.where((k) => !isMastered(k) && learningOf(k)).toList()..shuffle(rng);
  final fresh = items.where((k) => !isMastered(k) && !learningOf(k)).toList()..shuffle(rng);
  if (count <= 0) return [...learning, ...fresh, ...known]..shuffle(rng);
  final head = learning.take((count * 0.7).ceil()).toList();
  final all = [...head, ...fresh, ...learning.skip(head.length), ...known];
  return all.take(count).toList()..shuffle(rng);
}

/// Tạo bộ câu hỏi.
/// [targets]: các chữ cần hỏi. [all]: kho để lấy đáp án nhiễu.
/// [count] <= 0 nghĩa là hỏi hết [targets].
List<Question> buildQuiz({
  required List<Kanji> targets,
  required List<Kanji> all,
  required QuizMode mode,
  int count = 10,
  Random? random,
}) {
  final rng = random ?? Random();
  final picked = [...targets]..shuffle(rng);
  final selected =
      (count <= 0 || count >= picked.length) ? picked : picked.sublist(0, count);

  return selected.map((k) {
    final correct = answerOf(k, mode);
    final distractors = <String>{};
    final pool = [...all]..shuffle(rng);
    for (final other in pool) {
      if (distractors.length == 3) break;
      final a = answerOf(other, mode);
      if (a != correct) distractors.add(a);
    }
    final options = [correct, ...distractors]..shuffle(rng);
    return Question(
      kanji: k,
      options: options,
      correctIndex: options.indexOf(correct),
    );
  }).toList();
}
