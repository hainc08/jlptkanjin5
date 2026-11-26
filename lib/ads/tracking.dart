import 'package:app_tracking_transparency/app_tracking_transparency.dart';

/// iOS: hỏi App Tracking Transparency một lần trước khi SDK quảng cáo chạy (Apple 5.1.2).
/// Từ chối thì AdMob vẫn hiện quảng cáo không dùng IDFA.
Future<void> askTracking({
  required bool isIos,
  Future<TrackingStatus> Function()? status,
  Future<void> Function()? request,
  // Hộp thoại chỉ hiện khi app đang ở trạng thái active; chờ khung đầu xong.
  Duration delay = const Duration(milliseconds: 500),
}) async {
  if (!isIos) return;
  try {
    final current = await (status?.call() ?? AppTrackingTransparency.trackingAuthorizationStatus);
    if (current != TrackingStatus.notDetermined) return;
    await Future<void>.delayed(delay);
    await (request?.call() ?? AppTrackingTransparency.requestTrackingAuthorization());
  } catch (_) {
    // Không hỏi được thì vẫn tiếp tục với quảng cáo không cá nhân hóa.
  }
}
