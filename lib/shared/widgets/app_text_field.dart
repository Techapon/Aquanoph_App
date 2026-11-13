import 'package:flutter/material.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';

/// Label-over-input per Figma "NamDee" form style (setting pond 304:195 / add-pond 61:536):
/// label Nunito Bold 14 #707070, gap 8, input r8 border 1px #D9D9D9, text 16 #232323, hint #B3B3B3.
/// [unit] renders a side select-box (m² / kg / m) like add-pond's paired inputs.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? unit;
  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.unit,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.validator,
    this.onTap,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _field()),
            if (unit != null) ...[
              const SizedBox(width: 8),
              _unitBox(unit!),
            ],
          ],
        ),
      ],
    );
  }

  Widget _field() => TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: validator,
        onTap: onTap,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, color: AppColors.textHint),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          isDense: true,
          enabledBorder: _border(AppColors.neutralBorder, 1),
          focusedBorder: _border(AppColors.gradientStart, 1.5),
          border: _border(AppColors.neutralBorder, 1),
          errorBorder: _border(AppColors.danger, 1),
          focusedErrorBorder: _border(AppColors.danger, 1.5),
          errorStyle: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: AppColors.danger),
        ),
      );

  // add-pond "Select" box: same chrome, fixed ~84px, centered 16 text + chevron hint omitted
  Widget _unitBox(String unit) => Container(
        height: 49,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutralBorder, width: 1),
          color: Colors.white,
        ),
        child: Text(unit, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, color: AppColors.textPrimary)),
      );

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
}
