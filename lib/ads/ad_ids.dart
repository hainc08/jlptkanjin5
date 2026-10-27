import 'package:flutter/foundation.dart';

/// Mã đơn vị quảng cáo AdMob.
///
/// - Bản debug/profile: luôn dùng mã TEST của Google (không bao giờ click quảng cáo thật khi test).
/// - Bản release: dùng mã thật của tài khoản AdMob (pub-2898831437808228) bên dưới,
///   có thể ghi đè bằng --dart-define. Mã quảng cáo không phải thông tin bí mật.
class AdIds {
  static const _bannerAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: 'ca-app-pub-2898831437808228/2070916442',
  );
  static const _bannerIos = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    defaultValue: 'ca-app-pub-2898831437808228/3524645092',
  );
  static const _interAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: 'ca-app-pub-2898831437808228/1672507372',
  );
  static const _interIos = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
    defaultValue: 'ca-app-pub-2898831437808228/8444753104',
  );

  // Mã test chính thức của Google AdMob.
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/9214589741';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2435281174';
  static const _testInterAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _testInterIos = 'ca-app-pub-3940256099942544/4411468910';

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  static String? _pick(String android, String ios, String testAndroid, String testIos) {
    if (!kReleaseMode) return _isIos ? testIos : testAndroid;
    final id = _isIos ? ios : android;
    return id.isEmpty ? null : id;
  }

  static String? get banner =>
      _pick(_bannerAndroid, _bannerIos, _testBannerAndroid, _testBannerIos);

  static String? get interstitial =>
      _pick(_interAndroid, _interIos, _testInterAndroid, _testInterIos);
}
