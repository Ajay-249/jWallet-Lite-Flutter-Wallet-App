import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/status_badge.dart';
import 'send_money_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Details',
              style: AppTextStyles.headlineSerif(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${transaction.category ?? 'P2P'} INSTANT CLEARING',
              style: AppTextStyles.label(
                fontSize: 9,
                color: AppColors.textMuted,
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
                      'Transaction Details: ${CurrencyFormatter.format(transaction.amount)} | ID: ${transaction.id} | Status: ${transaction.status}',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction details copied')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            color: AppColors.onSurface,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt downloaded as PDF')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Column(
                children: [
                  transaction.status == 'FAILED'
                      ? StatusBadge.error(
                          label: 'FAILED • NOT DEBITED',
                        )
                      : StatusBadge.success(
                          label: '${transaction.status} • SETTLED',
                        ),
                  const SizedBox(height: 12),
                  Text(
                    '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                    style: AppTextStyles.balanceSerif(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: isCredit
                          ? const Color(0xFF2E7D32)
                          : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE8D8).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Zero Fee Instant UPI Transfer',
                          style: AppTextStyles.label(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cleared Timestamp',
                              style: AppTextStyles.label(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormatter.formatFull(transaction.createdAt),
                              style: AppTextStyles.bodySans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.verified_outlined,
                          size: 18,
                          color: Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Beneficiary / Sender Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE8D8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            transaction.beneficiaryName.trim().isNotEmpty
                                ? transaction.beneficiaryName
                                    .trim()
                                    .split(RegExp(r'\s+'))
                                    .where((e) => e.isNotEmpty)
                                    .map((e) => e[0])
                                    .take(2)
                                    .join()
                                    .toUpperCase()
                                : 'NA',
                            style: AppTextStyles.bodySans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  transaction.beneficiaryName,
                                  style: AppTextStyles.bodySans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                StatusBadge.tag(
                                  label: isCredit ? 'Sender' : 'Beneficiary',
                                ),
                              ],
                            ),
                            Text(
                              '${transaction.beneficiaryName.toLowerCase().replaceAll(' ', '')}@okaxis',
                              style: AppTextStyles.bodySans(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            if (transaction.mobileNumber != null)
                              Text(
                                transaction.mobileNumber!,
                                style: AppTextStyles.bodySans(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_rounded,
                                size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              'SBI •••• 9812',
                              style: AppTextStyles.bodySans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'IFSC: SBIN0004521',
                          style: AppTextStyles.label(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.wallet_rounded,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCredit ? 'Credited To' : 'Debited From',
                                  style: AppTextStyles.label(
                                    fontSize: 9,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  'Primary Wallet (Alex Varma)',
                                  style: AppTextStyles.bodySans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                  ),
                  if (transaction.status == 'FAILED') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4E0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFEF9A9A), width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FAILURE REASON',
                                  style: AppTextStyles.label(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                                ),
                                Text(
                                  transaction.remarks ?? 'Insufficient Funds',
                                  style: AppTextStyles.bodySans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (transaction.remarks != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded,
                              size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PURPOSE • NOTE',
                                  style: AppTextStyles.label(
                                    fontSize: 9,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  transaction.remarks == null ||
                                          transaction.remarks!.trim().isEmpty ||
                                          transaction.remarks == 'NA'
                                      ? 'NA'
                                      : '“${transaction.remarks}”',
                                  style: AppTextStyles.bodySans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment Summary Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Summary',
                        style: AppTextStyles.headlineSerif(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StatusBadge.tag(label: 'UPI 2.0 PROTOCOL'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSummaryRow(
                      'Transfer Amount', CurrencyFormatter.format(transaction.amount)),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Convenience & Platform Fee', '₹0.00 (FREE)',
                      isFree: true),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Applicable GST (18%)', '₹0.00'),
                  const Divider(color: AppColors.outlineLight, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCredit ? 'Total Credited Amount' : 'Total Debited Amount',
                        style: AppTextStyles.bodySans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(transaction.amount),
                        style: AppTextStyles.headlineSerif(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isCredit
                              ? const Color(0xFF2E7D32)
                              : AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Security & Ledger Proof Card (Dark Card)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            size: 15,
                            color: Color(0xFFE2CFC2),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SECURITY & LEDGER PROOF',
                            style: AppTextStyles.label(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE2CFC2),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '256-BIT SSL',
                          style: AppTextStyles.label(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TXN REFERENCE ID',
                              style: AppTextStyles.label(
                                fontSize: 9,
                                color: const Color(0xFFB5A89E),
                              ),
                            ),
                            Text(
                              transaction.id,
                              style: AppTextStyles.bodySans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: Color(0xFFF0DDD0),
                          ),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: transaction.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reference ID copied'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildProofCol('NPCI UTR',
                          transaction.id.replaceAll(RegExp(r'\D'), '')),
                      _buildProofCol('IDEMPOTENCY KEY', 'IDEMP-8F29A-2024'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildProofCol('AUTH CODE', 'AUTH-88219-OK'),
                      _buildProofCol('CLEARING TYPE', 'IMMEDIATE P2P'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Repeat Payment CTA
            if (!isCredit)
              CustomButton(
                text: 'Repeat This Payment',
                prefixIcon: Icons.repeat_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SendMoneyScreen(
                        prefilledName: transaction.beneficiaryName,
                        prefilledMobile: transaction.mobileNumber ?? '9876543210',
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Download PDF',
                    prefixIcon: Icons.picture_as_pdf_outlined,
                    isOutlined: true,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading receipt PDF')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: 'Share Proof',
                    prefixIcon: Icons.share_outlined,
                    isOutlined: true,
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              'Receipt for ${CurrencyFormatter.format(transaction.amount)} to ${transaction.beneficiaryName}. Ref: ${transaction.id}',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receipt shared')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.help_outline_rounded,
                    size: 15, color: AppColors.textMuted),
                label: Text(
                  'Need Help or Raise Dispute?',
                  style: AppTextStyles.bodySans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Support ticket created for dispute'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySans(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isFree ? const Color(0xFF2E7D32) : AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildProofCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label(
            fontSize: 9,
            color: const Color(0xFFB5A89E),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFBE8D8),
          ),
        ),
      ],
    );
  }
}
