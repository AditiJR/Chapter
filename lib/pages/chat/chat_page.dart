import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/theme.dart';
import '../../widgets/chapter_top_bar.dart';

class _Message {
  const _Message(this.text, {required this.mine});
  final String text;
  final bool mine;
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.name});

  final String name;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _messages = <_Message>[
    const _Message('Did you finish Piranesi yet?', mine: false),
    const _Message('Last night! Still thinking about the ending', mine: true),
    const _Message('No spoilers please. Adding it to my TBR', mine: false),
    const _Message('You will love it. I put it on my Favorites shelf',
        mine: true),
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add(_Message(text, mine: true)));
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ChapterTopBar(title: widget.name),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                children: [
                  Center(
                    child: Text('Today',
                        style: ChapterText.labelMedium
                            .copyWith(color: ChapterColors.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 10),
                  for (final m in _messages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Align(
                        alignment: m.mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: m.mine
                                ? ChapterColors.primary
                                : ChapterColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            m.text,
                            style: ChapterText.bodyMedium.copyWith(
                              color: m.mine
                                  ? ChapterColors.onPrimary
                                  : ChapterColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
                        style: ChapterText.bodyLarge
                            .copyWith(color: ChapterColors.onSurface),
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
                        child: SvgPicture.asset('assets/icons/send.svg',
                            width: 22, height: 22),
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
