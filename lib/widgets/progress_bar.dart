import 'package:flutter/material.dart';

/// Thanh tiến độ 2 lớp: lớp nhạt = đã học, lớp đậm = đã thuộc.
class LearnBar extends StatelessWidget {
  const LearnBar({
    super.key,
    required this.learned,
    required this.mastered,
    required this.color,
    this.height = 6,
    this.background,
  });

  final double learned;
  final double mastered;
  final Color color;
  final double height;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: background ?? color.withValues(alpha: 0.15)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: learned.clamp(0, 1),
              child: ColoredBox(color: color.withValues(alpha: 0.45)),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: mastered.clamp(0, 1),
              child: ColoredBox(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
