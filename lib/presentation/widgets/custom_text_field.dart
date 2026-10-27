import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final Widget? trailingBadge;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.trailingBadge,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.label(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            ?trailingBadge,
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          onChanged: onChanged,
          validator: validator,
          style: AppTextStyles.bodySans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySans(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
