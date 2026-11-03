import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_text_field.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ChapterColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                            'assets/icons/book_open_light.svg',
                            width: 28,
                            height: 28),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Welcome back', style: ChapterText.headlineMedium),
                    const SizedBox(height: 14),
                    Text('Sign in to pick up where you left off.',
                        style: ChapterText.bodyLarge),
                    const SizedBox(height: 30),
                    const ChapterTextField(
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    const ChapterTextField(label: 'Password', obscureText: true),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () =>
                            context.push(MyNavigatorRoute.resetPassword.path),
                        child: Text('Forgot password?',
                            style: ChapterText.labelLarge
                                .copyWith(color: ChapterColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ChapterButton(
                      label: 'Sign in',
                      onPressed: () =>
                          context.go(MyNavigatorRoute.permissions.path),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: ChapterColors.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or', style: ChapterText.bodySmall),
                        ),
                        const Expanded(
                            child: Divider(color: ChapterColors.outlineVariant)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ChapterButton(
                      label: 'Continue with Google',
                      type: ChapterButtonType.outlined,
                      onPressed: () =>
                          context.go(MyNavigatorRoute.permissions.path),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New to Chapter?', style: ChapterText.bodyMedium),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => context.go(MyNavigatorRoute.signUp.path),
                          child: Text('Create account',
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
    );
  }
}
