import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';

/// Splash 1 -> 3: the logo tile fades in and grows, then the wordmark and
/// tagline appear. Afterwards we continue to onboarding.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _stage = 0; // 0 = splash 1, 1 = splash 2, 2 = splash 3
  final _timers = <Timer>[];

  @override
  void initState() {
    super.initState();
    _timers.addAll([
      Timer(const Duration(milliseconds: 300), () => _setStage(1)),
      Timer(const Duration(milliseconds: 1100), () => _setStage(2)),
      Timer(const Duration(milliseconds: 2600), () {
        if (mounted) context.go(MyNavigatorRoute.onboarding.path);
      }),
    ]);
  }

  void _setStage(int stage) {
    if (mounted) setState(() => _stage = stage);
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 600);
    final large = _stage >= 1;
    return Scaffold(
      backgroundColor: ChapterColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              width: large ? 96 : 56,
              height: large ? 96 : 56,
              decoration: BoxDecoration(
                color: ChapterColors.onPrimary,
                borderRadius: BorderRadius.circular(large ? 24 : 14),
              ),
              child: Center(
                child: large
                    ? SvgPicture.asset('assets/icons/logo_book_large.svg',
                        width: 48, height: 48)
                    : SvgPicture.asset('assets/icons/logo_book.svg',
                        width: 28, height: 28),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: _stage >= 2 ? 1 : 0,
              duration: duration,
              child: Column(
                children: [
                  Text(
                    'Chapter',
                    style: ChapterText.lora(44, 52, FontWeight.w700,
                        color: ChapterColors.onPrimary),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: 0.85,
                    child: Text(
                      'Log every page. Shelf every story.',
                      style: ChapterText.bodyLarge
                          .copyWith(color: ChapterColors.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
