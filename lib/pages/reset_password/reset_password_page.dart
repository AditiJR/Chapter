import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_text_field.dart';
import '../../widgets/chapter_top_bar.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthenticationBloc>().add(
      AuthenticationPasswordResetEvent(email: _email.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationPasswordResetSent) {
          context.go(MyNavigatorRoute.resetLinkSent.path);
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
            const ChapterTopBar(title: 'Reset password'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forgot your password?',
                      style: ChapterText.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter the email you signed up with and we will send you a link to reset it.',
                      style: ChapterText.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ChapterTextField(
                      label: 'Email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Spacer(),
                    ChapterButton(
                      label: 'Send reset link',
                      loading: loading,
                      onPressed: _submit,
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
