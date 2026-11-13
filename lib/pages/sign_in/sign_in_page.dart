import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_text_field.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthenticationBloc>().add(
      AuthenticationSignInEvent(email: _email.text, password: _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationAuthenticated) {
          context.go(MyNavigatorRoute.library.path);
        }
        if (state is AuthenticationError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorText)));
        }
      },
      child: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final loading =
        context.watch<AuthenticationBloc>().state is AuthenticationWaiting;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
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
                          height: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Welcome back', style: ChapterText.headlineMedium),
                    const SizedBox(height: 14),
                    Text(
                      'Sign in to pick up where you left off.',
                      style: ChapterText.bodyLarge,
                    ),
                    const SizedBox(height: 30),
                    ChapterTextField(
                      label: 'Email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    ChapterTextField(
                      label: 'Password',
                      controller: _password,
                      obscureText: true,
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () =>
                            context.push(MyNavigatorRoute.resetPassword.path),
                        child: Text(
                          'Forgot password?',
                          style: ChapterText.labelLarge.copyWith(
                            color: ChapterColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ChapterButton(
                      label: 'Sign in',
                      loading: loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: ChapterColors.outlineVariant),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or', style: ChapterText.bodySmall),
                        ),
                        const Expanded(
                          child: Divider(color: ChapterColors.outlineVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ChapterButton(
                      label: 'Continue with Google',
                      type: ChapterButtonType.outlined,
                      onPressed: () => ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Google sign-in is not set up yet.'),
                          ),
                        ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New to Chapter?', style: ChapterText.bodyMedium),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => context.go(MyNavigatorRoute.signUp.path),
                          child: Text(
                            'Create account',
                            style: ChapterText.labelLarge.copyWith(
                              color: ChapterColors.primary,
                            ),
                          ),
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
