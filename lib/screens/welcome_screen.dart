import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/levels.dart';
import '../widgets/content_width.dart';
import '../widgets/level_card.dart';

import 'home_shell.dart';

/// Màn chào hỏi lần đầu: người dùng tự chọn cấp bắt đầu.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _choose(BuildContext context, JlptLevel level) {
    AppScope.read(context).currentLevel = level;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: contentPadding(context, top: 32),
          children: [
            Text('Chào bạn!', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Bạn muốn bắt đầu từ cấp nào? Đổi lại được trong Cài đặt.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            for (final l in JlptLevel.values) ...[
              LevelCard(level: l, onTap: () => _choose(context, l)),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
