import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/authentication/authentication_bloc.dart';
import '../../../model/friend.dart';
import '../../../model/user_profile.dart';
import '../../../repositories/users/user_repository.dart';
import '../../../theme/theme.dart';
import '../../../widgets/chapter_avatar.dart';

/// Lists the other people using Chapter and opens a chat with the one picked.
Future<void> showNewMessageSheet(BuildContext context) {
  final me = context.read<AuthenticationBloc>().user!;
  final users = context.read<UserRepository>();
  final router = GoRouter.of(context);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: ChapterColors.background,
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.of(sheetContext).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text('New message', style: ChapterText.headlineMedium),
          ),
          Expanded(
            child: FutureBuilder<List<UserProfile>>(
              future: users.listUsers(excludeUid: me.uid),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Could not load people.\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: ChapterText.bodyMedium,
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final people = snap.data!;
                if (people.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No one else has joined Chapter yet. Create a second '
                        'account to try messaging.',
                        textAlign: TextAlign.center,
                        style: ChapterText.bodyMedium,
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    for (final p in people)
                      ListTile(
                        leading: const ChapterAvatar(
                          tone: AvatarTone.peach,
                          size: 52,
                        ),
                        title: Text(
                          p.displayName,
                          style: ChapterText.titleMedium,
                        ),
                        subtitle: Text(p.handle, style: ChapterText.bodyMedium),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          router.push(
                            '/chat/${Uri.encodeComponent(p.uid)}',
                            extra: p.displayName,
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
