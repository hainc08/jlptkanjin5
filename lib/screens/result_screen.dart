import 'package:flutter/material.dart';

import '../ads/banner_ad_slot.dart';
import '../logic/quiz.dart';
import '../models/app_settings.dart';
import '../theme.dart';
import 'settings_screen.dart';
import 'test_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.questions, required this.mode});

  final List<Question> questions;
  final QuizMode mode;

  ({String title, String subtitle}) _message(double pct) {
    if (pct >= 0.9) {
      return (title: 'Xuất sắc! 🎉', subtitle: 'Bạn nắm Kanji N5 rất chắc.');
    }
    if (pct >= 0.7) {
      return (title: 'Tốt lắm!', subtitle: 'Ôn thêm vài chữ nữa là hoàn hảo.');
    }
    if (pct >= 0.5) {
      return (title: 'Khá ổn', subtitle: 'Hãy ôn lại các câu sai bên dưới.');
    }
    return (title: 'Cố lên nhé!', subtitle: 'Luyện thêm mỗi ngày sẽ tiến bộ nhanh.');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = questions.length;
    final correct = questions.where((q) => q.isCorrect).length;
    final wrong = questions.where((q) => !q.isCorrect).toList();
    final pct = total == 0 ? 0.0 : correct / total;
    final msg = _message(pct);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kết quả'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cài đặt',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(child: _ScoreRing(pct: pct, correct: correct, total: total)),
          const SizedBox(height: 18),
          Text(
            msg.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            msg.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatBox(
                label: 'Đúng',
                value: '$correct',
                color: AppColors.correct,
              ),
              const SizedBox(width: 10),
              _StatBox(
                label: 'Sai',
                value: '${wrong.length}',
                color: scheme.error,
              ),
              const SizedBox(width: 10),
              _StatBox(
                label: 'Kiểu câu hỏi',
                value: mode.label,
                color: scheme.primary,
                small: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (wrong.isEmpty)
            const _PerfectBox(color: AppColors.correct)
          else ...[
            Text(
              'Cần ôn lại (${wrong.length})',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...wrong.map((q) => _WrongTile(question: q)),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              if (wrong.isNotEmpty) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Ôn câu sai'),
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => TestScreen(
                          targets: wrong.map((q) => q.kanji).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Làm bài mới'),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const TestScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
            const BannerAdSlot(),
          ],
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.pct,
    required this.correct,
    required this.total,
  });

  final double pct;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: pct),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: v,
              strokeWidth: 14,
              strokeCap: StrokeCap.round,
              backgroundColor: scheme.surfaceContainerHighest,
              color: scheme.primary,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(v * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '$correct/$total câu đúng',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    this.small = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: small ? 13 : 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WrongTile extends StatelessWidget {
  const _WrongTile({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final k = question.kanji;
    final chosen = question.chosen == null ? '—' : question.options[question.chosen!];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              k.char,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: scheme.onPrimaryContainer,
                locale: kJapanese,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${k.hanViet} · ${k.meaning}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  k.readingLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                    locale: kJapanese,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bạn chọn: $chosen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.error,
                    locale: kJapanese,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfectBox extends StatelessWidget {
  const _PerfectBox({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: color, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Không sai câu nào. Thử tăng số câu hoặc đổi kiểu câu hỏi trong Cài đặt nhé!',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
