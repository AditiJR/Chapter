import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Two quick permissions', style: ChapterText.headlineMedium),
              const SizedBox(height: 16),
              Text(
                'Chapter works best with these. You can change them anytime in Settings.',
                style: ChapterText.bodyLarge,
              ),
              const SizedBox(height: 16),
              const _PermissionCard(
                icon: 'assets/icons/scan_permission.svg',
                title: 'Camera',
                body: "Used only to scan a book's ISBN barcode so it can be added to your shelves instantly.",
                action: 'Allow camera',
              ),
              const SizedBox(height: 16),
              const _PermissionCard(
                icon: 'assets/icons/bell_permission.svg',
                title: 'Notifications',
                body:
                    'Get a nudge when a friend follows you or sends a message.',
                action: 'Allow notifications',
              ),
              const Spacer(),
              ChapterButton(
                label: 'Continue',
                onPressed: () => context.go(MyNavigatorRoute.library.path),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.go(MyNavigatorRoute.library.path),
                  child: Text(
                    'Not now',
                    style: ChapterText.labelLarge.copyWith(
                      color: ChapterColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
  });

  final String icon;
  final String title;
  final String body;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ChapterColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: ChapterColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(icon, width: 24, height: 24),
              ),
              const SizedBox(width: 12),
              Text(title, style: ChapterText.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          Text(body, style: ChapterText.bodyMedium),
          const SizedBox(height: 12),
          ChapterButton(
            label: action,
            type: ChapterButtonType.tonal,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
