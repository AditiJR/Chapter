import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_text_field.dart';
import '../../widgets/chapter_top_bar.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ChapterTopBar(
              title: 'Create account',
              onBack: () => context.go(MyNavigatorRoute.signIn.path),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 32),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start your reading log',
                              style: ChapterText.headlineMedium),
                          const SizedBox(height: 14),
                          Text(
                            'Free forever for unlimited shelves, tags and following.',
                            style: ChapterText.bodyLarge,
                          ),
                          const SizedBox(height: 14),
                          const ChapterTextField(label: 'Display name'),
                          const SizedBox(height: 14),
                          const ChapterTextField(
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          const ChapterTextField(
                              label: 'Password', obscureText: true),
                          const SizedBox(height: 14),
                          Text(
                            'By creating an account you agree to the Terms and Privacy Policy.',
                            style: ChapterText.bodySmall,
                          ),
                          const SizedBox(height: 14),
                          ChapterButton(
                            label: 'Create account',
                            onPressed: () =>
                                context.go(MyNavigatorRoute.permissions.path),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                      color: ChapterColors.outlineVariant)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('or', style: ChapterText.bodySmall),
                              ),
                              const Expanded(
                                  child: Divider(
                                      color: ChapterColors.outlineVariant)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ChapterButton(
                            label: 'Sign up with Google',
                            type: ChapterButtonType.outlined,
                            onPressed: () =>
                                context.go(MyNavigatorRoute.permissions.path),
                          ),
                          const Spacer(),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account?',
                                  style: ChapterText.bodyMedium),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    context.go(MyNavigatorRoute.signIn.path),
                                child: Text('Sign in',
                                    style: ChapterText.labelLarge
                                        .copyWith(color: ChapterColors.primary)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
