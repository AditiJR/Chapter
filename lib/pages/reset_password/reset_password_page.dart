import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_text_field.dart';
import '../../widgets/chapter_top_bar.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ChapterTopBar(title: 'Reset password'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Forgot your password?',
                        style: ChapterText.headlineMedium),
                    const SizedBox(height: 16),
                    Text(
                      'Enter the email you signed up with and we will send you a link to reset it.',
                      style: ChapterText.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    const ChapterTextField(
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Spacer(),
                    ChapterButton(
                      label: 'Send reset link',
                      onPressed: () =>
                          context.go(MyNavigatorRoute.resetLinkSent.path),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
