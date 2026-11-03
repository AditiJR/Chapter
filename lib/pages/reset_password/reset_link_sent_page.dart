import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';

class ResetLinkSentPage extends StatelessWidget {
  const ResetLinkSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: ChapterColors.primaryContainer,
                  borderRadius: BorderRadius.circular(60),
                ),
                child:
                    SvgPicture.asset('assets/icons/mail.svg', width: 48, height: 48),
              ),
              const SizedBox(height: 16),
              Text('Check your inbox',
                  textAlign: TextAlign.center,
                  style: ChapterText.headlineMedium),
              const SizedBox(height: 16),
              Text(
                'We sent a reset link to your email. It expires in 30 minutes.',
                textAlign: TextAlign.center,
                style: ChapterText.bodyLarge,
              ),
              const Spacer(),
              ChapterButton(
                label: 'Back to sign in',
                onPressed: () => context.go(MyNavigatorRoute.signIn.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
