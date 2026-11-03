import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';

/// Shows an in-app "push notification" banner at the top of the screen.
void showPushBanner(
  BuildContext context, {
  required String sender,
  required String message,
  VoidCallback? onTap,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _PushBanner(
      sender: sender,
      message: message,
      onTap: onTap,
      onDismissed: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _PushBanner extends StatefulWidget {
  const _PushBanner({
    required this.sender,
    required this.message,
    required this.onDismissed,
    this.onTap,
  });

  final String sender;
  final String message;
  final VoidCallback onDismissed;
  final VoidCallback? onTap;

  @override
  State<_PushBanner> createState() => _PushBannerState();
}

class _PushBannerState extends State<_PushBanner> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => setState(() => _visible = true));
    _timer = Timer(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    setState(() => _visible = false);
    Future.delayed(const Duration(milliseconds: 300), widget.onDismissed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 8;
    return Positioned(
      left: 12,
      right: 12,
      top: top,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, -1.6),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Material(
          color: ChapterColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: ChapterColors.outlineVariant),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              _dismiss();
              widget.onTap?.call();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ChapterColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SvgPicture.asset('assets/icons/book_open_push.svg',
                          width: 22, height: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Chapter · ${widget.sender}',
                                style: ChapterText.labelMedium.copyWith(
                                    color: ChapterColors.onSurfaceVariant),
                              ),
                            ),
                            Text('now',
                                style: ChapterText.labelSmall.copyWith(
                                    color: ChapterColors.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: ChapterText.bodyMedium
                              .copyWith(color: ChapterColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
