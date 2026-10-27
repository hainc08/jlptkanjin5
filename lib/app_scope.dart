import 'package:flutter/widgets.dart';

import 'models/app_settings.dart';

/// Đưa [AppSettings] xuống toàn bộ cây widget.
class AppScope extends InheritedNotifier<AppSettings> {
  const AppScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  /// Đọc và tự rebuild khi cài đặt thay đổi.
  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Đọc một lần (dùng trong callback), không đăng ký rebuild.
  static AppSettings read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
