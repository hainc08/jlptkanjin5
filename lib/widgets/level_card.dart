import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../theme.dart';

/// Thẻ một cấp JLPT: khối màu tên cấp, số chữ, mô tả, 3 chữ mẫu, tiến độ (nếu có).
/// Dùng chung cho màn Chào hỏi và tab Các cấp.
class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.level,
    this.percent,
    this.highlighted = false,
    this.onTap,
  });

  final JlptLevel level;

  /// Tỉ lệ đã thuộc 0..1; null = không hiện thanh tiến độ.
  final double? percent;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = kanjiOf(level);
    final c = level.color;
    return Material(
      color: c.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: highlighted ? c : c.withValues(alpha: 0.25), width: highlighted ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  level.label,
                  style: const TextStyle(
                    fontFamily: 'NotoSerif',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('${items.length} chữ', style: const TextStyle(fontWeight: FontWeight.w600)),
                        _Badge(text: level.description, color: c),
                        if (highlighted) _Badge(text: 'Đang học', color: c, solid: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (percent != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 6,
                          color: c,
                          backgroundColor: c.withValues(alpha: 0.15),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(percent! * 100).round()}% đã thuộc',
                        style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.7)),
                      ),
                    ] else
                      Row(
                        children: [
                          for (final k in items.take(3))
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                border: Border.all(color: scheme.outlineVariant),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(k.char, style: kanjiStyle(18)),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color, this.solid = false});

  final String text;
  final Color color;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: solid ? Colors.white : color),
      ),
    );
  }
}
