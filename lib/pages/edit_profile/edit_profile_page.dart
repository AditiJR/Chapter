import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../model/user_profile.dart';
import '../../repositories/authentication/authentication_repository.dart';
import '../../repositories/users/user_repository.dart';
import '../../theme/theme.dart';
import '../../utilities/guarded.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_text_field.dart';
import '../../widgets/chapter_top_bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();

  UserProfile? _profile;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthenticationBloc>().user!;
    UserProfile? profile;
    try {
      profile = await context.read<UserRepository>().getProfile(user.uid);
    } catch (_) {}
    profile ??= UserProfile.fromUser(user);
    if (!mounted) return;
    _profile = profile;
    _name.text = profile.displayName;
    _username.text = profile.username;
    _bio.text = profile.bio;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final username = _username.text
        .trim()
        .replaceAll('@', '')
        .replaceAll(' ', '')
        .toLowerCase();
    if (name.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and username cannot be empty.')),
      );
      return;
    }
    final users = context.read<UserRepository>();
    final auth = context.read<AuthenticationRepository>();
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    var saved = false;
    await guarded(context, () async {
      await users.updateProfile(
        _profile!.copyWith(
          displayName: name,
          username: username,
          bio: _bio.text.trim(),
        ),
      );
      await auth.updateDisplayName(name);
      saved = true;
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) router.pop();
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ChapterTopBar(title: 'Edit profile'),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
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
                              _profile?.initial ?? '?',
                              style: ChapterText.lora(
                                26,
                                34,
                                FontWeight.w600,
                                color: ChapterColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          ChapterTextField(
                            label: 'Display name',
                            controller: _name,
                          ),
                          const SizedBox(height: 14),
                          ChapterTextField(
                            label: 'Username',
                            controller: _username,
                          ),
                          const SizedBox(height: 14),
                          ChapterTextField(label: 'Bio', controller: _bio),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ChapterButton(
                label: _saving ? 'Saving…' : 'Save changes',
                onPressed: _loading || _saving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
