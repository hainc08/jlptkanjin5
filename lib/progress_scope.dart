import 'package:flutter/widgets.dart';

import 'data/progress_store.dart';

/// Đưa [ProgressStore] xuống toàn bộ cây widget.
class ProgressScope extends InheritedNotifier<ProgressStore> {
  const ProgressScope({
    super.key,
    required ProgressStore progress,
    required super.child,
  }) : super(notifier: progress);

  /// Đọc và tự rebuild khi tiến độ thay đổi.
  static ProgressStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProgressScope>()!.notifier!;

  /// Đọc một lần (dùng trong callback), không đăng ký rebuild.
  static ProgressStore read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ProgressScope>()!.notifier!;
}
