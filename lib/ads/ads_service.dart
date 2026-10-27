import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

/// Quản lý xin phép (UMP consent), khởi tạo AdMob và quảng cáo toàn màn hình.
class AdsService {
  AdsService._();

  static final instance = AdsService._();

  /// true khi đã có thể yêu cầu quảng cáo (đã qua bước consent và đã khởi tạo SDK).
  final ValueNotifier<bool> canShowAds = ValueNotifier(false);

  bool _initStarted = false;
  InterstitialAd? _interstitial;
  int _finishedQuizzes = 0;
  DateTime? _lastInterstitial;

  /// AdMob chỉ chạy trên Android và iOS.
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> init() async {
    if (!supported || _initStarted) return;
    _initStarted = true;

    await _gatherConsent();
    if (!await ConsentInformation.instance.canRequestAds()) return;

    await MobileAds.instance.initialize();
    canShowAds.value = true;
    _loadInterstitial();
  }

  /// Hiện form consent (GDPR ở EU/UK, câu hỏi theo dõi quảng cáo trên iOS)
  /// nếu Google yêu cầu. Cấu hình nội dung form trong AdMob → Privacy & messaging.
  Future<void> _gatherConsent() {
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) => finish()),
      (_) => finish(),
    );
    return done.future;
  }

  /// Màn Cài đặt dùng để quyết định có hiện mục "Quyền riêng tư quảng cáo" không.
  Future<bool> privacyOptionsRequired() async {
    if (!supported) return false;
    final status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  void showPrivacyOptions() => ConsentForm.showPrivacyOptionsForm((_) {});

  void _loadInterstitial() {
    final id = AdIds.interstitial;
    if (id == null || !canShowAds.value) return;
    InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Gọi khi người dùng làm xong một lượt test.
  /// Chỉ hiện quảng cáo toàn màn hình sau mỗi 2 lượt và cách nhau ít nhất 90 giây.
  Future<void> onQuizFinished() async {
    _finishedQuizzes++;
    final ad = _interstitial;
    if (ad == null || _finishedQuizzes % 2 != 0) return;
    final last = _lastInterstitial;
    if (last != null &&
        DateTime.now().difference(last) < const Duration(seconds: 90)) {
      return;
    }

    final closed = Completer<void>();
    void finish(InterstitialAd shown) {
      shown.dispose();
      _interstitial = null;
      _loadInterstitial();
      if (!closed.isCompleted) closed.complete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: finish,
      onAdFailedToShowFullScreenContent: (shown, _) => finish(shown),
    );
    _interstitial = null;
    _lastInterstitial = DateTime.now();
    await ad.show();
    await closed.future.timeout(const Duration(minutes: 2), onTimeout: () {});
  }
}
