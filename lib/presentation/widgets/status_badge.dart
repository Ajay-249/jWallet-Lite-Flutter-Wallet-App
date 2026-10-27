import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
  });

  factory StatusBadge.success({required String label}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.successLight,
      textColor: AppColors.success,
      borderColor: AppColors.successBorder,
      icon: Icons.check_circle_outline,
    );
  }

  factory StatusBadge.tag({required String label}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.surfaceContainer,
      textColor: AppColors.onSurfaceVariant,
      borderColor: AppColors.outlineLight,
    );
  }

  factory StatusBadge.gold({required String label, IconData? icon}) {
    return StatusBadge(
      label: label,
      backgroundColor: const Color(0xFFFBF4E6),
      textColor: const Color(0xFFB87818),
      borderColor: const Color(0xFFF2DEB5),
      icon: icon,
    );
  }

  factory StatusBadge.error({required String label}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.errorLight,
      textColor: AppColors.error,
      borderColor: AppColors.errorBorder,
      icon: Icons.error_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.label(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor ?? AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
