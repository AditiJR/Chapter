import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/friend.dart';

/// Round placeholder avatar. The Figma file ships these as pre-sized SVGs, so
/// only some tone/size pairs exist; others fall back to a same-tone or yellow
/// circle scaled to [size].
class ChapterAvatar extends StatelessWidget {
  const ChapterAvatar({super.key, required this.tone, required this.size});

  final AvatarTone tone;
  final int size;

  static const _available = {
    'yellow_44',
    'yellow_36',
    'yellow_52',
    'yellow_88',
    'peach_36',
    'peach_52',
    'pink_52',
  };

  String get _asset {
    final exact = '${tone.name}_$size';
    if (_available.contains(exact)) return exact;
    final sameTone = _available.where((a) => a.startsWith('${tone.name}_'));
    return sameTone.isNotEmpty ? sameTone.first : 'yellow_$size';
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/avatars/$_asset.svg',
      width: size.toDouble(),
      height: size.toDouble(),
    );
  }
}
