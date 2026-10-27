import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../widgets/custom_button.dart';
import '../widgets/status_badge.dart';
import 'home_dashboard_screen.dart';
import 'send_money_screen.dart';
import 'transaction_history_screen.dart';

class TransferSuccessScreen extends StatelessWidget {
  final String transactionId;
  final double amount;
  final String beneficiaryName;
  final String mobileNumber;
  final String remarks;
  final String idempotencyKey;
  final double postBalance;
  final String? senderName;

  const TransferSuccessScreen({
    super.key,
    required this.transactionId,
    required this.amount,
    required this.beneficiaryName,
    required this.mobileNumber,
    required this.remarks,
    required this.idempotencyKey,
    required this.postBalance,
    this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedTime =
        'Today, ${DateFormat('hh:mm a • dd MMM yyyy').format(now)}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Home',
                style: AppTextStyles.headlineSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              color: AppColors.onSurface,
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text:
                        'Transfer Successful: ${CurrencyFormatter.format(amount)} to $beneficiaryName. UTR: $transactionId',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Receipt details copied to clipboard'),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Concentric Green Success Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9).withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC8E6C9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Status Tag
              StatusBadge.success(label: 'COMPLETED / SETTLED'),
              const SizedBox(height: 12),

              // Headline & Timestamp
              Text(
                'Transfer Successful',
                style: AppTextStyles.headlineSerif(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: AppTextStyles.bodySans(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              Text(
                CurrencyFormatter.format(amount),
                style: AppTextStyles.balanceSerif(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Zero Fee Instant UPI Transfer',
                      style: AppTextStyles.label(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Available Balance Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBE8D8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Balance',
                              style: AppTextStyles.bodySans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'JW-LITE-094',
                              style: AppTextStyles.label(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(postBalance),
                          style: AppTextStyles.bodySans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '-${CurrencyFormatter.format(amount)}',
                          style: AppTextStyles.label(
                            fontSize: 10,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Beneficiary Receipt Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  beneficiaryName.trim().isNotEmpty
                                      ? beneficiaryName
                                          .trim()
                                          .split(RegExp(r'\s+'))
                                          .where((e) => e.isNotEmpty)
                                          .map((e) => e[0])
                                          .take(2)
                                          .join()
                                          .toUpperCase()
                                      : 'NA',
                                  style: AppTextStyles.bodySans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                beneficiaryName,
                                style: AppTextStyles.bodySans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${beneficiaryName.toLowerCase().replaceAll(' ', '')}@okaxis',
                                style: AppTextStyles.bodySans(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                'State Bank of India •••• 9812',
                                style: AppTextStyles.bodySans(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge.tag(label: 'P2P'),
                      ],
                    ),
                    const Divider(color: AppColors.outlineLight, height: 24),
                    _buildReceiptRow(
                        'Paid From', '${senderName ?? "Ajay Dwivedi"} • Wallet'),
                    const SizedBox(height: 10),
                    _buildReceiptRow('Remark',
                        remarks.trim().isEmpty || remarks.trim() == 'NA'
                            ? 'NA'
                            : remarks),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'UPI Ref / UTR',
                          style: AppTextStyles.bodySans(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: transactionId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reference copied to clipboard'),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                transactionId,
                                style: AppTextStyles.bodySans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.copy_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NPCI Idempotency',
                          style: AppTextStyles.bodySans(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  idempotencyKey,
                                  style: AppTextStyles.label(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.lock_rounded,
                                size: 12,
                                color: Color(0xFF2E7D32),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons Row: Share & Repeat
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Share Receipt',
                      prefixIcon: Icons.share_outlined,
                      isOutlined: true,
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                'Payment Receipt: ${CurrencyFormatter.format(amount)} to $beneficiaryName. UTR: $transactionId',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receipt link copied'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: 'Repeat Transfer',
                      prefixIcon: Icons.repeat_rounded,
                      isOutlined: true,
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => SendMoneyScreen(
                              prefilledName: beneficiaryName,
                              prefilledMobile: mobileNumber,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Split with others box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBE8D8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.group_add_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Split with others?',
                            style: AppTextStyles.bodySans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Split this ${CurrencyFormatter.format(amount)} bill across friends',
                            style: AppTextStyles.bodySans(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Split bill feature is demo ready'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Split',
                        style: AppTextStyles.button(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Primary CTA: Back to Home Dashboard
              CustomButton(
                text: 'Back to Home Dashboard',
                suffixIcon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const HomeDashboardScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Secondary CTA: View in History
              CustomButton(
                text: 'View in Transaction History',
                prefixIcon: Icons.receipt_long_rounded,
                isOutlined: true,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const TransactionHistoryScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySans(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodySans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
