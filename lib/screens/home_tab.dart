import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/levels.dart';
import '../data/progress_store.dart';
import '../progress_scope.dart';
import '../theme.dart';
import '../widgets/content_width.dart';

import 'test_screen.dart';

/// Trang chủ: tiến độ 5 cấp, tiếp tục học, chuỗi ngày, chữ cần ôn.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _openQuiz(BuildContext context, JlptLevel level,
      [List<Kanji>? targets]) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => TestScreen(level: level, targets: targets)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final progress = ProgressScope.of(context);
    final level = settings.currentLevel ?? JlptLevel.n5;
    final items = kanjiOf(level);
    final pct = progress.percent(level, items);
    final next = level.next;
    final review = progress.needsReview(level, items);

    return Scaffold(
      appBar: AppBar(title: const Text('Kanji JLPT')),
      body: ListView(
        padding: contentPadding(context),
        children: [
          _LevelsStrip(progress: progress),
          const SizedBox(height: 16),
          _ContinueCard(
            level: level,
            mastered: progress.masteredCount(level, items),
            total: items.length,
            percent: pct,
            onTap: () => _openQuiz(context, level),
          ),
          if (next != null && pct >= ProgressStore.nextLevelThreshold) ...[
            const SizedBox(height: 10),
            _NextLevelHint(
              from: level,
              to: next,
              onTap: () => settings.currentLevel = next,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  color: const Color(0xFFE65100),
                  icon: Icons.local_fire_department_outlined,
                  label: 'Chuỗi học tập',
                  value: '${progress.streakDays} ngày',
                  note: 'liên tiếp',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  color: const Color(0xFF2E7D32),
                  icon: Icons.edit_note,
                  label: 'Hôm nay',
                  value: '${progress.todayCount} chữ',
                  note: 'đã ôn luyện',
                ),
              ),
            ],
          ),
          if (review.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Cần ôn lại',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            // Đủ chỗ (iPad) thì 4 ô một hàng, điện thoại thì 2×2.
            LayoutBuilder(
              builder: (context, box) {
                final wide = box.maxWidth >= 520;
                return GridView.count(
                  crossAxisCount: wide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: wide ? 0.85 : 1.25,
                  children: [
                    for (final k in review.take(4))
                      _ReviewTile(
                          key: const ValueKey('review-tile'),
                          kanji: k,
                          color: level.color),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Ôn các chữ này'),
              onPressed: () => _openQuiz(context, level, review),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dải tiến độ cả 5 cấp, mỗi cấp một màu.
class _LevelsStrip extends StatelessWidget {
  const _LevelsStrip({required this.progress});

  final ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            for (final l in JlptLevel.values) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.label} ${(progress.percent(l, kanjiOf(l)) * 100).round()}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: l.color),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress.percent(l, kanjiOf(l)),
                        minHeight: 6,
                        color: l.color,
                        backgroundColor: l.color.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
              if (l != JlptLevel.n1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.level,
    required this.mastered,
    required this.total,
    required this.percent,
    required this.onTap,
  });

  final JlptLevel level;
  final int mastered;
  final int total;
  final double percent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: level.color, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: white.withValues(alpha: 0.7)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(level.label,
                    style: const TextStyle(
                        color: white, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Tiếp tục học',
                  style: TextStyle(
                      fontFamily: 'NotoSerif',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Đã thuộc $mastered/$total chữ',
                  style: const TextStyle(
                      color: white, fontWeight: FontWeight.w600),
                ),
              ),
              Text('${(percent * 100).round()}%',
                  style: const TextStyle(
                      color: white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              color: white,
              backgroundColor: white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: white, foregroundColor: level.color),
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Học tiếp'),
          ),
        ],
      ),
    );
  }
}

class _NextLevelHint extends StatelessWidget {
  const _NextLevelHint(
      {required this.from, required this.to, required this.onTap});

  final JlptLevel from;
  final JlptLevel to;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: to.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.explore_outlined, color: to.color),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      '${from.label} gần xong, thử bắt đầu ${to.label} →')),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(label,
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.w600))),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontFamily: 'NotoSerif',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: color),
          ),
          Text(note, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({super.key, required this.kanji, required this.color});

  final Kanji kanji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(kanji.char, style: kanjiStyle(36, color: color)),
          const SizedBox(height: 4),
          Text(kanji.hanViet,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          Text(
            kanji.meaning,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
