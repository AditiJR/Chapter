import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';
import 'views/onboarding_illustrations.dart';

class _Slide {
  const _Slide({
    required this.illustration,
    required this.title,
    required this.body,
    required this.dots,
    required this.cta,
  });

  final Widget illustration;
  final String title;
  final String body;
  final String dots;
  final String cta;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    _Slide(
      illustration: ScanIllustration(),
      title: 'Scan a barcode.\nDone.',
      body: "Point your camera at a book's ISBN and Chapter fills in the title, author and cover for you.",
      dots: 'assets/illustrations/page_dots_1.svg',
      cta: 'Next',
    ),
    _Slide(
      illustration: ShelvesIllustration(),
      title: 'Shelves that work\nyour way',
      body: 'Create unlimited shelves like “Currently reading”, “2026 favorites” or “DNF” and tag books to find them fast.',
      dots: 'assets/illustrations/page_dots_2.svg',
      cta: 'Next',
    ),
    _Slide(
      illustration: FriendsIllustration(),
      title: 'Read together',
      body: 'Follow friends, see what they are shelving and chat about the book you both love.',
      dots: 'assets/illustrations/page_dots_3.svg',
      cta: 'Get started',
    ),
  ];

  bool get _isLast => _index == _slides.length - 1;

  void _next() {
    if (_isLast) {
      context.go(MyNavigatorRoute.signIn.path);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _isLast
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: () => context.go(MyNavigatorRoute.signIn.path),
                          child: Text(
                            'Skip',
                            style: ChapterText.labelLarge.copyWith(
                              color: ChapterColors.primary,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        slide.illustration,
                        const SizedBox(height: 20),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: ChapterText.headlineMedium,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: ChapterText.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        SvgPicture.asset(slide.dots, width: 56, height: 8),
                        const Spacer(),
                        ChapterButton(label: slide.cta, onPressed: _next),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
