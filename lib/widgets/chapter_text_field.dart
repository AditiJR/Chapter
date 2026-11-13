import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ChapterTextField extends StatelessWidget {
  const ChapterTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ChapterColors.outline),
    );
    return SizedBox(
      height: 56,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: ChapterText.bodyLarge.copyWith(color: ChapterColors.onSurface),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: ChapterText.bodyLarge,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: border,
          border: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(
              color: ChapterColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
