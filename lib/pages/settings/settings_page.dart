import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_dialog.dart';
import '../../widgets/chapter_top_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _followers = true;
  bool _messages = true;
  bool _activity = false;

  Future<void> _signOut() async {
    final confirmed = await showChapterDialog<bool>(
      context,
      icon: SvgPicture.asset('assets/icons/log_out_large.svg',
          width: 28, height: 28),
      title: 'Sign out of Chapter?',
      body: 'Your library stays safe in the cloud. Sign back in anytime.',
      actions: [
        DialogAction(
          label: 'Cancel',
          onTap: () => Navigator.of(context).pop(false),
        ),
        DialogAction(
          label: 'Sign out',
          filledColor: ChapterColors.error,
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed == true && mounted) {
      context.go(MyNavigatorRoute.signIn.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ChapterTopBar(title: 'Settings'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const _GroupTitle('Account'),
                  _Row(
                    icon: 'assets/icons/user_row.svg',
                    label: 'Profile',
                    value: 'Aditi',
                    onTap: () =>
                        context.push(MyNavigatorRoute.editProfile.path),
                  ),
                  const _Row(
                    icon: 'assets/icons/mail_row.svg',
                    label: 'Email',
                    value: 'a***@gmail.com',
                  ),
                  const _Row(
                    icon: 'assets/icons/lock.svg',
                    label: 'Password',
                  ),
                  const _GroupTitle('Notifications'),
                  _ToggleRow(
                    icon: 'assets/icons/user_plus_row.svg',
                    label: 'New followers',
                    value: _followers,
                    onChanged: (v) => setState(() => _followers = v),
                  ),
                  _ToggleRow(
                    icon: 'assets/icons/message_row.svg',
                    label: 'Messages',
                    value: _messages,
                    onChanged: (v) => setState(() => _messages = v),
                  ),
                  _ToggleRow(
                    icon: 'assets/icons/bell_row.svg',
                    label: 'Friend activity',
                    value: _activity,
                    onChanged: (v) => setState(() => _activity = v),
                  ),
                  const _GroupTitle('Chapter Premium'),
                  _Row(
                    icon: 'assets/icons/crown_row.svg',
                    label: 'Upgrade to Premium',
                    value: r'$4.99/mo',
                    onTap: () => context.push(MyNavigatorRoute.premium.path),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: ChapterColors.error),
                ),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: _signOut,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/log_out.svg',
                            width: 22, height: 22),
                        const SizedBox(width: 12),
                        Text('Sign out',
                            style: ChapterText.labelLarge
                                .copyWith(color: ChapterColors.error)),
                      ],
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

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
      child: Text(text,
          style:
              ChapterText.labelLarge.copyWith(color: ChapterColors.primary)),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  final String icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(icon, width: 24, height: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: ChapterText.bodyLarge
                      .copyWith(color: ChapterColors.onSurface)),
            ),
            if (value != null) ...[
              Text(value!, style: ChapterText.bodyMedium),
              const SizedBox(width: 16),
            ],
            SvgPicture.asset('assets/icons/chevron_right.svg',
                width: 20, height: 20),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(icon, width: 24, height: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: ChapterText.bodyLarge
                      .copyWith(color: ChapterColors.onSurface)),
            ),
            SvgPicture.asset(
              value
                  ? 'assets/icons/switch_on.svg'
                  : 'assets/icons/switch_off.svg',
              width: 52,
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}
