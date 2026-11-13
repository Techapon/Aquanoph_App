import 'package:flutter/material.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';

/// Label-over-input per Figma "NamDee" form style (setting pond 304:195 / add-pond 61:536):
/// label Nunito Bold 14 #707070, gap 8, input r8 border 1px #D9D9D9, text 16 #232323, hint #B3B3B3.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
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
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
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
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
}
