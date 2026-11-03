import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    ('Library', 'assets/icons/book_open.svg'),
    ('Search', 'assets/icons/search.svg'),
    ('Scan', 'assets/icons/scan_nav.svg'),
    ('Friends', 'assets/icons/users.svg'),
    ('Profile', 'assets/icons/user.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 84,
        color: ChapterColors.surfaceContainer,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < _items.length; i++)
              InkWell(
                onTap: () => navigationShell.goBranch(
                  i,
                  initialLocation: i == navigationShell.currentIndex,
                ),
                child: SizedBox(
                  width: 68,
                  height: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 4),
                        decoration: BoxDecoration(
                          color: i == selected
                              ? ChapterColors.secondaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SvgPicture.asset(_items[i].$2,
                            width: 24, height: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _items[i].$1,
                        style: ChapterText.labelMedium.copyWith(
                          color: i == selected
                              ? ChapterColors.onSurface
                              : ChapterColors.onSurfaceVariant,
                        ),
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
