import 'dart:async';

import 'package:flutter/material.dart';

import '../ads/ads_service.dart';
import '../app_scope.dart';
import '../data/levels.dart';
import '../theme.dart';
import 'home_shell.dart';
import 'welcome_screen.dart';

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

  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Xin phép quảng cáo + khởi tạo AdMob song song với splash.
    unawaited(AdsService.instance.init());
    _timer = Timer(const Duration(milliseconds: 2200), _goNext);
  }

  /// Lần đầu (chưa chọn cấp) → Chào hỏi; các lần sau → Trang chủ.
  void _goNext() {
    if (!mounted) return;
    final first = AppScope.read(context).currentLevel == null;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => first ? const WelcomeScreen() : const HomeShell(),
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
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            children: [
              const Spacer(flex: 3),
              const _Seal(),
              const SizedBox(height: 32),
              Text('Kanji JLPT', style: theme.textTheme.displaySmall),
              const SizedBox(height: 8),
              Text('Flashcard N5 – N1', style: TextStyle(fontSize: 16, color: muted, letterSpacing: 0.5)),
              const SizedBox(height: 28),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final l in JlptLevel.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: CircleAvatar(radius: 5, backgroundColor: l.color),
                    ),
                ],
              ),
              const Spacer(flex: 4),
              Text.rich(
                TextSpan(
                  text: 'Một sản phẩm từ ',
                  style: TextStyle(fontSize: 13, color: muted),
                  children: [
                    TextSpan(
                      text: 'ManabiHub',
                      style: TextStyle(
                        fontFamily: 'NotoSerif',
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

/// Con dấu hanko đỏ chứa chữ 漢字.
class _Seal extends StatelessWidget {
  const _Seal();

  static const _red = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: _red, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.08),
          border: Border.all(color: _red.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '漢\n字',
          textAlign: TextAlign.center,
          style: kanjiStyle(38, weight: FontWeight.w700, color: AppColors.ink).copyWith(height: 1.05),
        ),
      ),
    );
  }
}
