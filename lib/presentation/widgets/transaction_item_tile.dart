import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/transaction_model.dart';
import 'status_badge.dart';

class TransactionItemTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionItemTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  IconData _getCategoryIcon() {
    if (transaction.status == 'FAILED') {
      return Icons.close_rounded;
    }
    switch (transaction.category?.toUpperCase()) {
      case 'MERCHANT':
        return Icons.coffee_rounded;
      case 'DINING':
        return Icons.restaurant_rounded;
      case 'BONUS':
      case 'REWARD':
        return Icons.card_giftcard_rounded;
      case 'NEFT':
        return Icons.account_balance_rounded;
      case 'REFUND':
        return Icons.directions_car_rounded;
      case 'UTILITY':
        return Icons.bolt_rounded;
      default:
        return transaction.isCredit
            ? Icons.south_west_rounded
            : Icons.north_east_rounded;
    }
  }

  Color _getIconBackgroundColor() {
    if (transaction.isCredit) {
      return const Color(0xFFE8F5E9);
    }
    return const Color(0xFFFCE4E0);
  }

  Color _getIconColor() {
    if (transaction.isCredit) {
      return const Color(0xFF2E7D32);
    }
    return const Color(0xFFC0392B);
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineLight, width: 0.8),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(),
                size: 20,
                color: _getIconColor(),
              ),
            ),
            const SizedBox(width: 12),

            // Middle Column: Beneficiary & Meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          transaction.beneficiaryName,
                          style: AppTextStyles.bodySans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (transaction.category != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction.category!,
                            style: AppTextStyles.label(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.id} • ${DateFormatter.formatShort(transaction.createdAt)}',
                    style: AppTextStyles.bodySans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right Column: Amount & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                  style: AppTextStyles.bodySans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: transaction.status == 'FAILED'
                        ? AppColors.error
                        : isCredit
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC0392B),
                    decoration: transaction.status == 'FAILED'
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 3),
                transaction.status == 'FAILED'
                    ? StatusBadge.error(label: 'FAILED')
                    : StatusBadge(
                        label: transaction.status,
                        backgroundColor: isCredit
                            ? const Color(0xFFE8F5E9)
                            : AppColors.surfaceContainer,
                        textColor: isCredit
                            ? const Color(0xFF2E7D32)
                            : AppColors.onSurfaceVariant,
                        borderColor: isCredit
                            ? const Color(0xFFA5D6A7)
                            : AppColors.outlineLight,
                      ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
