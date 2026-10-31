import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Bề rộng tối đa của cột nội dung: trên iPad / màn rộng, nội dung nằm giữa thay vì kéo giãn.
const kMaxContentWidth = 640.0;

/// Padding cho danh sách cuộn: lề hai bên tự nới ra để nội dung không rộng quá [kMaxContentWidth].
EdgeInsets contentPadding(
  BuildContext context, {
  double side = 20,
  double top = 8,
  double bottom = 24,
}) {
  final w = MediaQuery.sizeOf(context).width;
  final h = math.max(side, (w - kMaxContentWidth) / 2);
  return EdgeInsets.fromLTRB(h, top, h, bottom);
}

/// Đặt [child] vào cột giữa rộng tối đa [kMaxContentWidth] (dùng cho màn không cuộn).
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: child,
      ),
    );
  }
}
