import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ShelfCard extends StatelessWidget {
  const ShelfCard({
    super.key,
    required this.name,
    required this.count,
    this.onTap,
  });

  final String name;
  final String count;
  final VoidCallback? onTap;

  static const _coverColors = [
    ChapterColors.primary,
    ChapterColors.tertiary,
    ChapterColors.secondary,
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChapterColors.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
                width: 40 * 3 - 18 * 2,
                child: Stack(
                  children: [
                    for (var i = 0; i < _coverColors.length; i++)
                      Positioned(
                        left: i * 22.0,
                        child: Container(
                          width: 40,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _coverColors[i],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(name, style: ChapterText.titleMedium),
              const SizedBox(height: 10),
              Text(count, style: ChapterText.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
