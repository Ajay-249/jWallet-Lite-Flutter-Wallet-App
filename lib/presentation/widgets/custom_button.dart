import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.suffixIcon,
    this.prefixIcon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            side: BorderSide(
              color: backgroundColor ?? AppColors.outline,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _buildContent(textColor ?? AppColors.onSurface),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _buildContent(textColor ?? Colors.white),
      ),
    );
  }

  Widget _buildContent(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: 16, color: contentColor),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.button(
              color: contentColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: 6),
          Icon(suffixIcon, size: 16, color: contentColor),
        ],
      ],
    );
  }
}
