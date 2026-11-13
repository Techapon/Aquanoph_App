import 'package:flutter/material.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';

/// Figma "Select" box (add-pond 154:139): label over a field-styled container
/// (r8, 1px #D9D9D9, h49, text 16) with a chevron; tap opens a bottom sheet of options.
class AppSelectField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const AppSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _pick(context),
          child: Container(
            height: 49,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neutralBorder, width: 1),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(value, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, color: AppColors.textPrimary)),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (final option in options)
              ListTile(
                title: Text(option, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, color: AppColors.textPrimary)),
                trailing: option == value ? const Icon(Icons.check, color: AppColors.gradientStart) : null,
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
          ],
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }
}
