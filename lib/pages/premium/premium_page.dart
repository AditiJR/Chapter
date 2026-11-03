import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_dialog.dart';

enum _Plan {
  monthly('Monthly', 'Cancel anytime', r'$4.99/mo', r'$4.99/month'),
  yearly('Yearly', 'Save 33%', r'$39.99/yr', r'$39.99/year');

  const _Plan(this.title, this.caption, this.price, this.cta);
  final String title;
  final String caption;
  final String price;
  final String cta;
}

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  _Plan _plan = _Plan.monthly;

  static const _features = [
    'Custom shelf cover art',
    'Advanced filtering and sorting',
    'Ad-free experience',
  ];

  Future<void> _subscribe() async {
    await showChapterDialog<void>(
      context,
      icon: SvgPicture.asset('assets/icons/crown_dialog.svg',
          width: 28, height: 28),
      title: 'Welcome to Premium',
      body:
          'Custom covers, advanced filters and an ad-free experience are now unlocked.',
      actions: [
        DialogAction(
          label: 'Start exploring',
          filledColor: ChapterColors.primary,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
    if (mounted) context.go(MyNavigatorRoute.profile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset('assets/icons/x_dark.svg',
                          width: 24, height: 24),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: ChapterColors.tertiaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset('assets/icons/crown_hero.svg',
                            width: 36, height: 36),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Chapter Premium',
                      style: ChapterText.lora(34, 42, FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    Text('Make your shelves truly yours.',
                        style: ChapterText.bodyLarge),
                    const SizedBox(height: 14),
                    for (final f in _features)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: ChapterColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SvgPicture.asset(
                                  'assets/icons/check_small.svg',
                                  width: 16,
                                  height: 16),
                            ),
                            const SizedBox(width: 12),
                            Text(f,
                                style: ChapterText.bodyLarge.copyWith(
                                    color: ChapterColors.onSurface)),
                          ],
                        ),
                      ),
                    for (final plan in _Plan.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _PlanCard(
                          plan: plan,
                          selected: plan == _plan,
                          onTap: () => setState(() => _plan = plan),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  ChapterButton(
                    label: 'Subscribe for ${_plan.cta}',
                    onPressed: _subscribe,
                  ),
                  const SizedBox(height: 14),
                  Text('Restore purchases',
                      style: ChapterText.labelLarge
                          .copyWith(color: ChapterColors.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ChapterColors.primaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected
              ? ChapterColors.primary
              : ChapterColors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.title, style: ChapterText.titleMedium),
                    Text(plan.caption, style: ChapterText.bodySmall),
                  ],
                ),
              ),
              Text(plan.price,
                  style: ChapterText.titleMedium
                      .copyWith(color: ChapterColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
