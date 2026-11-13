import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_text_field.dart';
import '../../widgets/chapter_top_bar.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ChapterTopBar(title: 'Edit profile'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: ChapterColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'A',
                        style: ChapterText.lora(
                          26,
                          34,
                          FontWeight.w600,
                          color: ChapterColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Change photo',
                      style: ChapterText.labelLarge.copyWith(
                        color: ChapterColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const ChapterTextField(label: 'Display name'),
                    const SizedBox(height: 14),
                    const ChapterTextField(label: 'Username'),
                    const SizedBox(height: 14),
                    const ChapterTextField(label: 'Bio'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ChapterButton(
                label: 'Save changes',
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
