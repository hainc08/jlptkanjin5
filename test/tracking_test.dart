import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_n5_flashcard/ads/tracking.dart';

void main() {
  Future<int> requests({required bool isIos, required TrackingStatus status, bool fails = false}) async {
    var count = 0;
    await askTracking(
      isIos: isIos,
      status: () async => fails ? throw StateError('lỗi') : status,
      request: () async => count++,
      delay: Duration.zero,
    );
    return count;
  }

  test('iOS chưa chọn → hỏi quyền theo dõi một lần', () async {
    expect(await requests(isIos: true, status: TrackingStatus.notDetermined), 1);
  });

  test('iOS đã chọn rồi → không hỏi lại', () async {
    for (final s in [TrackingStatus.authorized, TrackingStatus.denied, TrackingStatus.restricted]) {
      expect(await requests(isIos: true, status: s), 0, reason: '$s');
    }
  });

  test('không phải iOS → không hỏi', () async {
    expect(await requests(isIos: false, status: TrackingStatus.notDetermined), 0);
  });

  test('plugin lỗi → bỏ qua, quảng cáo vẫn khởi tạo tiếp', () async {
    expect(await requests(isIos: true, status: TrackingStatus.notDetermined, fails: true), 0);
  });
}
