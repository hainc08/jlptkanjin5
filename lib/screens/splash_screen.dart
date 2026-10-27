import 'dart:async';

import 'package:flutter/material.dart';

import '../ads/ads_service.dart';
import '../app_config.dart';
import '../data/levels.dart';
import '../theme.dart';
import 'test_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final Animation<double> _scale =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
  );

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Xin phép quảng cáo + khởi tạo AdMob song song với splash.
    unawaited(AdsService.instance.init());
    _timer = Timer(const Duration(milliseconds: 2200), _goToTest);
  }

  void _goToTest() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const TestScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.vermilion, AppColors.plum],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 132,
                    height: 132,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: const Text(
                      '漢',
                      style: TextStyle(
                        fontSize: 76,
                        fontWeight: FontWeight.w700,
                        color: AppColors.vermilion,
                        locale: kJapanese,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fade,
                child: const Column(
                  children: [
                    Text(
                      AppConfig.name,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Flashcard luyện thi JLPT',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              Text(
                '${appKanji.length} chữ Kanji · Phiên bản ${AppConfig.version}',
                style: const TextStyle(fontSize: 13, color: Colors.white60),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
