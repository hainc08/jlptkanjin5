import 'dart:math';

import 'package:flutter/material.dart';

/// Thẻ lật 3D: [front] khi showBack = false, [back] khi showBack = true.
class FlipCard extends StatelessWidget {
  const FlipCard({
    super.key,
    required this.showBack,
    required this.front,
    required this.back,
  });

  final bool showBack;
  final Widget front;
  final Widget back;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: showBack ? 1 : 0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      builder: (context, t, _) {
        final isBack = t > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(t * pi),
          child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}

/// Khung thẻ dùng chung cho mặt trước và mặt sau.
class CardShell extends StatelessWidget {
  const CardShell({super.key, required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor ?? scheme.outlineVariant,
          width: borderColor == null ? 1 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
