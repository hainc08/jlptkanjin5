import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/levels.dart';
import '../progress_scope.dart';
import '../widgets/content_width.dart';
import '../widgets/level_card.dart';

import 'test_screen.dart';

/// Tab Các cấp: tiến độ từng cấp, bấm để vào quiz của cấp đó (không đổi cấp đang học).
class LevelsTab extends StatelessWidget {
  const LevelsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final current = AppScope.of(context).currentLevel;
    final progress = ProgressScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Các cấp')),
      body: ListView(
        padding: contentPadding(context),
        children: [
          for (final l in JlptLevel.values) ...[
            LevelCard(
              level: l,
              percent: progress.percent(l, kanjiOf(l)),
              learned: progress.learnedPercent(l, kanjiOf(l)),
              highlighted: l == current,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TestScreen(level: l)),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Chọn một cấp để bắt đầu quiz',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
