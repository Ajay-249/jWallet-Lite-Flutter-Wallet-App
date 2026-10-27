import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/wallet_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'transfer_confirmation_screen.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  final String? prefilledName;
  final String? prefilledMobile;

  const SendMoneyScreen({super.key, this.prefilledName, this.prefilledMobile});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _nameError;
  String? _mobileError;
  String? _amountError;
  final String _selectedPaymentMode = 'UPI';

  @override
  void initState() {
    super.initState();
    if (widget.prefilledName != null) {
      _nameController.text = widget.prefilledName!;
    }
    if (widget.prefilledMobile != null) {
      _mobileController.text = widget.prefilledMobile!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _addAmount(double add) {
    final current = double.tryParse(_amountController.text) ?? 0.0;
    final total = current + add;
    setState(() {
      _amountController.text = total.toStringAsFixed(2);
      _amountError = null;
    });
  }

  void _setMaxAmount() {
    final available = ref.read(walletProvider).wallet?.availableBalance ?? 0.0;
    setState(() {
      _amountController.text = available.toStringAsFixed(2);
      _amountError = null;
    });
  }

  void _handleContinue() {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final amountText = _amountController.text.trim();
    final remarks = _remarksController.text.trim();
    // final balance = ref.read(walletProvider).wallet?.availableBalance ?? 0.0;

    setState(() {
      _nameError = null;
      _mobileError = null;
      _amountError = null;
    });

    bool isValid = true;

    // Beneficiary name validation
    if (name.isEmpty) {
      setState(() => _nameError = 'Beneficiary name is required');
      isValid = false;
    } else if (name.length < 3) {
      setState(() => _nameError = 'Name must be at least 3 characters');
      isValid = false;
    }

    // 10-digit mobile number validation
    final cleanMobile = mobile.replaceAll(RegExp(r'\D'), '');
    if (cleanMobile.isEmpty) {
      setState(() => _mobileError = 'Mobile number is required');
      isValid = false;
    } else if (cleanMobile.length != 10) {
      setState(() => _mobileError = 'Enter a valid 10-digit mobile number');
      isValid = false;
    }

    // Amount validation
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(
        () => _amountError = 'Transfer amount must be greater than zero',
      );
      isValid = false;
    }

    if (!isValid) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransferConfirmationScreen(
          beneficiaryName: name,
          mobileNumber: cleanMobile,
          amount: amount!,
          remarks: remarks.trim().isEmpty ? 'NA' : remarks.trim(),
          paymentMode: _selectedPaymentMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider).wallet;
    final availableBalance = wallet?.availableBalance ?? 24850.50;

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
              'Send Money',
              style: AppTextStyles.headlineSerif(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Instant transfers via UPI & IMPS',
              style: AppTextStyles.bodySans(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transfers are processed instantly via UPI'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source Account Banner (Dark Card)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SOURCE ACCOUNT',
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
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'INR ACTIVE',
                          style: AppTextStyles.label(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Primary Wallet (Ledger #094)',
                    style: AppTextStyles.bodySans(
                      fontSize: 12,
                      color: const Color(0xFFB5A89E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            CurrencyFormatter.format(availableBalance),
                            style: AppTextStyles.balanceSerif(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'avail',
                            style: AppTextStyles.bodySans(
                              fontSize: 12,
                              color: const Color(0xFFD6C8BE),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 12,
                              color: Color(0xFFFBE8D8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'KYC Tier 2',
                              style: AppTextStyles.label(
                                fontSize: 9,
                                color: const Color(0xFFFBE8D8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Frequent Payees Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FREQUENT PAYEES',
                  style: AppTextStyles.label(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  'View All',
                  style: AppTextStyles.label(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPayeeTile('Rahul S.', 'Recent', 'RS', () {
                  setState(() {
                    _nameController.text = 'Rahul Sharma';
                    _mobileController.text = '9876543210';
                  });
                }),
                _buildPayeeTile('Priya', 'UPI', 'PS', () {
                  setState(() {
                    _nameController.text = 'Priya Nair';
                    _mobileController.text = '9811233445';
                  });
                }),
                _buildPayeeTile('Amit', 'Mobile', 'AK', () {
                  setState(() {
                    _nameController.text = 'Amit Kumar';
                    _mobileController.text = '9765432109';
                  });
                }),
                _buildPayeeTile('Blue Tokai', 'Merchant', 'BT', () {
                  setState(() {
                    _nameController.text = 'Blue Tokai Coffee';
                    _mobileController.text = '9800012345';
                  });
                }),
              ],
            ),
            const SizedBox(height: 18),

            // Card: Beneficiary Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Beneficiary Name *',
                    controller: _nameController,
                    hint: 'e.g. Rahul Sharma',
                    errorText: _nameError,
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Mobile Number or UPI ID *',
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    hint: '98765 43210',
                    errorText: _mobileError,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_android_rounded,
                            color: AppColors.onSurfaceVariant,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+91',
                            style: AppTextStyles.bodySans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailingBadge: Text(
                      '10 digits',
                      style: AppTextStyles.label(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card: Transfer Amount
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
                        'TRANSFER AMOUNT *',
                        style: AppTextStyles.label(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Free Instant Transfer',
                          style: AppTextStyles.label(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Amount Input Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _amountError != null
                            ? AppColors.error
                            : AppColors.outlineLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '₹',
                          style: AppTextStyles.headlineSerif(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            style: AppTextStyles.balanceSerif(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: AppTextStyles.balanceSerif(
                                fontSize: 32,
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_amountError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _amountError!,
                      style: AppTextStyles.bodySans(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Fast Amount Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAmountChip('+₹500', () => _addAmount(500)),
                        const SizedBox(width: 6),
                        _buildAmountChip('+₹1,000', () => _addAmount(1000)),
                        const SizedBox(width: 6),
                        _buildAmountChip('+₹2,000', () => _addAmount(2000)),
                        const SizedBox(width: 6),
                        _buildAmountChip('+₹5,000', () => _addAmount(5000)),
                        const SizedBox(width: 6),
                        _buildAmountChip('Max', _setMaxAmount, isMax: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Wallet Balance: ${CurrencyFormatter.format(availableBalance)}',
                            style: AppTextStyles.bodySans(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Daily Limit: ₹50k',
                        style: AppTextStyles.label(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card: Remarks
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
                        'REMARKS / PURPOSE (OPTIONAL)',
                        style: AppTextStyles.label(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${_remarksController.text.length}/50',
                        style: AppTextStyles.label(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _remarksController,
                    maxLength: 50,
                    onChanged: (_) => setState(() {}),
                    style: AppTextStyles.bodySans(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'What is this for? (e.g., Rent, Dinner)',
                      prefixIcon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.onSurfaceVariant,
                        size: 18,
                      ),
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Compliance Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'NPCI / RBI Compliant • 256-bit Encrypted',
                      style: AppTextStyles.label(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            CustomButton(
              text: 'Continue to Review',
              suffixIcon: Icons.arrow_forward_rounded,
              onPressed: _handleContinue,
            ),
            const SizedBox(height: 10),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Step 1 of 2: Verify transfer details',
                    style: AppTextStyles.bodySans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPayeeTile(
    String name,
    String tag,
    String initials,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineLight),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFBE8D8),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppTextStyles.bodySans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: AppTextStyles.bodySans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              tag,
              style: AppTextStyles.label(
                fontSize: 9,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountChip(
    String label,
    VoidCallback onTap, {
    bool isMax = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMax
              ? const Color(0xFFFBE8D8)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isMax ? AppColors.primary : AppColors.outlineLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isMax ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
