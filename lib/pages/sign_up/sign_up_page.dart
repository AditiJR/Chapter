import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_text_field.dart';
import '../../widgets/chapter_top_bar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthenticationBloc>().add(
      AuthenticationSignUpEvent(
        displayName: _name.text,
        email: _email.text,
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationAuthenticated) {
          context.go(MyNavigatorRoute.permissions.path);
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
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start your reading log',
                            style: ChapterText.headlineMedium,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Free forever for unlimited shelves, tags and following.',
                            style: ChapterText.bodyLarge,
                          ),
                          const SizedBox(height: 14),
                          ChapterTextField(
                            label: 'Display name',
                            controller: _name,
                          ),
                          const SizedBox(height: 14),
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
                          Text(
                            'By creating an account you agree to the Terms and Privacy Policy.',
                            style: ChapterText.bodySmall,
                          ),
                          const SizedBox(height: 14),
                          ChapterButton(
                            label: 'Create account',
                            loading: loading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: ChapterColors.outlineVariant,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text('or', style: ChapterText.bodySmall),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: ChapterColors.outlineVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ChapterButton(
                            label: 'Sign up with Google',
                            type: ChapterButtonType.outlined,
                            onPressed: () => ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Google sign-in is not set up yet.',
                                  ),
                                ),
                              ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: ChapterText.bodyMedium,
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    context.go(MyNavigatorRoute.signIn.path),
                                child: Text(
                                  'Sign in',
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
          ],
        ),
      ),
    );
  }
}
