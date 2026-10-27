import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/wallet_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/status_badge.dart';
import 'transfer_failure_dialog.dart';
import 'transfer_success_screen.dart';

class TransferConfirmationScreen extends ConsumerStatefulWidget {
  final String beneficiaryName;
  final String mobileNumber;
  final double amount;
  final String remarks;
  final String paymentMode;

  const TransferConfirmationScreen({
    super.key,
    required this.beneficiaryName,
    required this.mobileNumber,
    required this.amount,
    required this.remarks,
    required this.paymentMode,
  });

  @override
  ConsumerState<TransferConfirmationScreen> createState() =>
      _TransferConfirmationScreenState();
}

class _TransferConfirmationScreenState
    extends ConsumerState<TransferConfirmationScreen> {
  bool _isProcessing = false;
  String? _errorMessage;
  late final String _idempotencyKey;

  @override
  void initState() {
    super.initState();
    _idempotencyKey = 'IDEMP-${const Uuid().v4().substring(0, 8).toUpperCase()}-2024';
  }

  void _handleConfirmTransfer() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    // Simulate network roundtrip latency
    await Future.delayed(const Duration(milliseconds: 900));

    final currentBalance =
        ref.read(walletProvider).wallet?.availableBalance ?? 0.0;

    // Process transfer through backend
    final success = await ref.read(walletProvider.notifier).processTransfer(
          beneficiaryName: widget.beneficiaryName,
          mobileNumber: widget.mobileNumber,
          amount: widget.amount,
          idempotencyKey: _idempotencyKey,
          remarks: widget.remarks,
        );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      final generatedRef =
          'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}';
      final currentUser = ref.read(walletProvider).user?.name ?? 'Ajay Dwivedi';
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TransferSuccessScreen(
            transactionId: generatedRef,
            amount: widget.amount,
            beneficiaryName: widget.beneficiaryName,
            mobileNumber: widget.mobileNumber,
            remarks: widget.remarks.trim().isEmpty ? 'NA' : widget.remarks.trim(),
            idempotencyKey: _idempotencyKey,
            postBalance: currentBalance - widget.amount,
            senderName: currentUser,
          ),
        ),
      );
    } else if (mounted) {
      final state = ref.read(walletProvider);
      final errorMsg = state.errorMessage ?? 'Payment Failed';
      final errCode = state.errorCode ?? 'PAYMENT_FAILED';
      setState(() {
        _isProcessing = false;
        _errorMessage = errorMsg;
      });
      TransferFailureDialog.show(
        context: context,
        errorCode: errCode,
        errorMessage: errorMsg,
        onRetry: () {
          if (mounted) {
            _handleConfirmTransfer();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider).wallet;
    final currentBalance = wallet?.availableBalance ?? 24850.50;
    final postBalance = currentBalance - widget.amount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transfer Confirmation',
          style: AppTextStyles.headlineSerif(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.security_rounded),
            color: AppColors.primary,
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 2 of 2 Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'STEP 2 OF 2: FINAL VERIFICATION',
                        style: AppTextStyles.label(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'NPCI Instant Protocol',
                    style: AppTextStyles.label(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main Dark Deduction Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF33261F),
                    Color(0xFF221A16),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'TRANSFER AMOUNT',
                    style: AppTextStyles.label(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD6C8BE),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(widget.amount),
                    style: AppTextStyles.balanceSerif(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 13,
                          color: Color(0xFF81C784),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Fee: ₹0.00 (Zero Surcharge UPI)',
                          style: AppTextStyles.label(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF0DDD0),
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
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Deduction',
                          style: AppTextStyles.bodySans(
                            fontSize: 13,
                            color: const Color(0xFFD6C8BE),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(widget.amount),
                          style: AppTextStyles.bodySans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Beneficiary Destination Card
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
                        'BENEFICIARY DESTINATION',
                        style: AppTextStyles.label(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      StatusBadge(
                        label: 'KYC MATCHED',
                        backgroundColor: AppColors.surfaceContainer,
                        textColor: AppColors.primary,
                        borderColor: AppColors.outlineLight,
                        icon: Icons.verified_user_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              widget.beneficiaryName.trim().isNotEmpty
                                  ? widget.beneficiaryName
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
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.beneficiaryName,
                                style: AppTextStyles.bodySans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                '${widget.beneficiaryName.toLowerCase().replaceAll(' ', '')}@okaxis',
                                style: AppTextStyles.bodySans(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                '+91 ${widget.mobileNumber}',
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
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.account_balance_rounded,
                    label: 'Destination Bank',
                    value: 'State Bank of India •••• 9812',
                  ),
                  const Divider(color: AppColors.outlineLight, height: 16),
                  _buildDetailRow(
                    icon: Icons.bolt_rounded,
                    label: 'Transfer Protocol',
                    customValue: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE8D8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'IMMEDIATE UPI V2',
                        style: AppTextStyles.label(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.outlineLight, height: 16),
                  _buildDetailRow(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Remarks Note',
                    value: widget.remarks.trim().isEmpty || widget.remarks == 'NA'
                        ? 'NA'
                        : '“${widget.remarks}”',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Debit Source Card
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
                        'DEBIT SOURCE ACCOUNT',
                        style: AppTextStyles.label(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'INR ACTIVE',
                          style: AppTextStyles.label(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Primary Wallet',
                            style: AppTextStyles.bodySans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Ledger Ref: JW-LITE-09418',
                            style: AppTextStyles.label(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Balance',
                                style: AppTextStyles.label(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(currentBalance),
                                style: AppTextStyles.bodySans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Post-Transfer Balance',
                                style: AppTextStyles.label(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(
                                    postBalance > 0 ? postBalance : 0.0),
                                style: AppTextStyles.bodySans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Protocol & Idempotency Safeguards Box
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
                      Row(
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Security & Protocol Safeguards',
                            style: AppTextStyles.bodySans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: AppTextStyles.label(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.fingerprint_rounded,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Idempotency Guard',
                              style: AppTextStyles.bodySans(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _idempotencyKey,
                            style: AppTextStyles.label(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '256-bit SSL Cryptographic Tunnel • Fully certified by NPCI & Reserve Bank of India framework. Deductions are strictly non-duplicable.',
                    style: AppTextStyles.bodySans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // In-screen error alert banner
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.bodySans(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Confirm Button
            CustomButton(
              text: 'Confirm & Pay ${CurrencyFormatter.format(widget.amount)}',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: Icons.arrow_forward_rounded,
              isLoading: _isProcessing,
              onPressed: _handleConfirmTransfer,
            ),
            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel or Edit Details',
                  style: AppTextStyles.button(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? customValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodySans(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        if (customValue != null)
          Flexible(child: customValue)
        else
          Flexible(
            child: Text(
              value ?? '',
              style: AppTextStyles.bodySans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
      ],
    );
  }
}
