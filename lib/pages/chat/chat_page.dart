import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../model/chat.dart';
import '../../repositories/chat/chat_repository.dart';
import '../../repositories/users/user_repository.dart';
import '../../theme/theme.dart';
import '../../utilities/guarded.dart';
import '../../widgets/chapter_top_bar.dart';

/// Live one-to-one chat with [uid], stored in Firestore.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.uid, this.name});

  final String uid;

  /// Shown in the top bar until the other user's profile loads.
  final String? name;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  late final String _myUid;
  late final String _chatId;
  late final Future<void> _ready;
  String? _name;

  @override
  void initState() {
    super.initState();
    final me = context.read<AuthenticationBloc>().user!;
    final chats = context.read<ChatRepository>();
    final users = context.read<UserRepository>();
    _myUid = me.uid;
    _chatId = chats.chatId(me.uid, widget.uid);
    _name = widget.name;
    _ready = _open(me.displayName, chats, users);
  }

  /// The chat document must exist before its messages can be read.
  Future<void> _open(
    String myName,
    ChatRepository chats,
    UserRepository users,
  ) async {
    final other = await users.getProfile(widget.uid);
    final otherName = other?.displayName ?? _name ?? 'Reader';
    if (mounted) setState(() => _name = otherName);
    await chats.openChat(
      myUid: _myUid,
      myName: myName,
      otherUid: widget.uid,
      otherName: otherName,
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await guarded(context, () async {
      await context.read<ChatRepository>().send(
        chatId: _chatId,
        senderId: _myUid,
        text: text,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ChapterTopBar(title: _name ?? 'Chat'),
            Expanded(
              child: FutureBuilder<void>(
                future: _ready,
                builder: (context, ready) {
                  if (ready.hasError) {
                    return Center(
                      child: Text(
                        'Could not open this chat.\n${ready.error}',
                        textAlign: TextAlign.center,
                        style: ChapterText.bodyMedium,
                      ),
                    );
                  }
                  if (ready.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return StreamBuilder<List<ChatMessage>>(
                    stream: context.read<ChatRepository>().watchMessages(
                      _chatId,
                    ),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            'Could not load messages.\n${snap.error}',
                            textAlign: TextAlign.center,
                            style: ChapterText.bodyMedium,
                          ),
                        );
                      }
                      final messages = snap.data ?? const <ChatMessage>[];
                      if (snap.hasData && messages.isEmpty) {
                        return Center(
                          child: Text(
                            'Say hi to ${_name ?? 'your friend'}!',
                            style: ChapterText.bodyMedium,
                          ),
                        );
                      }
                      _scrollToEnd();
                      return ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        children: [
                          for (final m in messages)
                            _Bubble(message: m, mine: m.senderId == _myUid),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: ChapterColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _send(),
                        style: ChapterText.bodyLarge.copyWith(
                          color: ChapterColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: ChapterText.bodyLarge,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: ChapterColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _send,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: SvgPicture.asset(
                          'assets/icons/send.svg',
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: mine ? ChapterColors.primary : ChapterColors.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            message.text,
            style: ChapterText.bodyMedium.copyWith(
              color: mine ? ChapterColors.onPrimary : ChapterColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
