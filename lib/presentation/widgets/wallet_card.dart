import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';

class WalletCard extends StatefulWidget {
  final double balance;
  final String maskedAccountNumber;
  final String ledgerId;
  final VoidCallback? onSendPressed;

  const WalletCard({
    super.key,
    required this.balance,
    required this.maskedAccountNumber,
    this.ledgerId = '#094',
    this.onSendPressed,
  });

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF33261F),
            Color(0xFF221A16),
            Color(0xFF1B1411),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF241C18).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Ledger tags & security
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE27C3E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PRIMARY WALLET',
                    style: AppTextStyles.label(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF0DDD0),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F3D24),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2E6336), width: 0.8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SECURE',
                      style: AppTextStyles.label(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF81C784),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'jWallet Lite Ledger ${widget.ledgerId}',
            style: AppTextStyles.bodySans(
              fontSize: 12,
              color: const Color(0xFFB5A89E),
            ),
          ),
          const SizedBox(height: 18),

          // Balance Header & Eye toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: AppTextStyles.bodySans(
                  fontSize: 13,
                  color: const Color(0xFFD6C8BE),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _isBalanceVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 15,
                      color: const Color(0xFFD6C8BE),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isBalanceVisible ? 'Hide' : 'Show',
                      style: AppTextStyles.bodySans(
                        fontSize: 12,
                        color: const Color(0xFFD6C8BE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Big Serif Balance
          Text(
            _isBalanceVisible
                ? CurrencyFormatter.format(widget.balance)
                : '₹ ••••••••',
            style: AppTextStyles.balanceSerif(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Bottom Bar: Masked Account & Copy
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.credit_card_outlined,
                      size: 17,
                      color: Color(0xFFD6C8BE),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.maskedAccountNumber,
                      style: AppTextStyles.bodySans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF0DDD0),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.maskedAccountNumber),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account number copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          size: 12,
                          color: Color(0xFFF0DDD0),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: AppTextStyles.label(
                            fontSize: 11,
                            color: const Color(0xFFF0DDD0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
