import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/status_badge.dart';

class TransferFailureDialog extends StatelessWidget {
  final String errorCode;
  final String errorMessage;
  final VoidCallback onRetry;

  const TransferFailureDialog({
    super.key,
    required this.errorCode,
    required this.errorMessage,
    required this.onRetry,
  });

  static void show({
    required BuildContext context,
    required String errorCode,
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransferFailureDialog(
        errorCode: errorCode,
        errorMessage: errorMessage,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInsufficient = errorCode.contains('INSUFFICIENT_BALANCE');
    String reasonText;
    if (isInsufficient) {
      reasonText = 'Insufficient Funds';
    } else if (errorCode.contains('SERVER') ||
        errorCode.contains('NETWORK') ||
        errorCode.contains('CONNECTION') ||
        errorMessage == 'Server Unavailable') {
      reasonText = 'Server Unavailable';
    } else if (errorCode.contains('TIMEOUT')) {
      reasonText = 'Request Timeout';
    } else {
      reasonText = errorCode;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Error Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4E0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEF9A9A), width: 1),
            ),
            child: Center(
              child: Icon(
                isInsufficient
                    ? Icons.account_balance_wallet_outlined
                    : Icons.error_outline_rounded,
                color: AppColors.error,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 16),

          StatusBadge.error(
            label: isInsufficient ? 'INSUFFICIENT BALANCE' : errorCode,
          ),
          const SizedBox(height: 12),

          Text(
            'Transaction Unsuccessful',
            style: AppTextStyles.headlineSerif(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEF9A9A), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cancel_outlined,
                  size: 15,
                  color: AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  'Reason: $reasonText',
                  style: AppTextStyles.bodySans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Text(
            errorMessage,
            style: AppTextStyles.bodySans(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineLight),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This failed attempt has been logged in your Transaction History. No money was debited from your account.',
                    style: AppTextStyles.bodySans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          CustomButton(
            text: 'Dismiss',
            prefixIcon: Icons.home_outlined,
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
