import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/wallet_state.dart';
import '../widgets/transaction_item_tile.dart';
import '../widgets/wallet_card.dart';
import 'login_screen.dart';
import 'send_money_screen.dart';
import 'transaction_details_screen.dart';
import 'transaction_history_screen.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _currentNavIndex = 0;

  void _showAddMoneyBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Money (Top-up)',
                    style: AppTextStyles.headlineSerif(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'UI ONLY',
                      style: AppTextStyles.label(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Per assignment specification, Add Money is a UI-only demonstration feature.',
                style: AppTextStyles.bodySans(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Column(
                  children: [
                    _buildPaymentOption(
                      Icons.account_balance_rounded,
                      'Net Banking / IMPS',
                    ),
                    const Divider(color: AppColors.outlineLight, height: 20),
                    _buildPaymentOption(Icons.qr_code_rounded, 'UPI QR Scan'),
                    const Divider(color: AppColors.outlineLight, height: 20),
                    _buildPaymentOption(
                      Icons.credit_card_rounded,
                      'Debit / Credit Card',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Done', style: AppTextStyles.button()),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodySans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Sign Out?',
          style: AppTextStyles.headlineSerif(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of jWallet Lite?',
          style: AppTextStyles.bodySans(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.button(color: AppColors.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(walletProvider.notifier).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Sign Out', style: AppTextStyles.button()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);
    final user = state.user;
    final wallet = state.wallet;
    final recentTransactions = state.transactions.take(5).toList();

    return Scaffold(
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.onSurface,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: _showLogoutDialog,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(walletProvider.notifier).refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Online/Offline bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: state.isServerOnline
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFD99B26),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.isServerOnline
                            ? 'SYSTEM: ONLINE • Synced just now'
                            : 'SYSTEM: OFFLINE • Local Cache Active',
                        style: AppTextStyles.label(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: state.isServerOnline
                              ? AppColors.textMuted
                              : const Color(0xFFB87818),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () =>
                        ref.read(walletProvider.notifier).refreshData(),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.outlineLight),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            size: 13,
                            color: state.isLoading
                                ? AppColors.textMuted
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            state.isLoading ? 'Syncing...' : 'Sync',
                            style: AppTextStyles.label(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // User Profile Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                user != null && user.name.trim().isNotEmpty
                                    ? user.name
                                          .trim()
                                          .split(RegExp(r'\s+'))
                                          .where((e) => e.isNotEmpty)
                                          .map((e) => e[0])
                                          .take(2)
                                          .join()
                                          .toUpperCase()
                                    : 'AD',
                                style: AppTextStyles.bodySans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Welcome,',
                                style: AppTextStyles.bodySans(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.name ?? 'Alex Varma',
                            style: AppTextStyles.headlineSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   children: [
                  //     StatusBadge.gold(
                  //       label: '250 PTS',
                  //       icon: Icons.stars_rounded,
                  //     ),
                  //     const SizedBox(height: 3),
                  //     Text(
                  //       'Tier: Lite Elite',
                  //       style: AppTextStyles.label(
                  //         fontSize: 10,
                  //         color: AppColors.textMuted,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
              const SizedBox(height: 18),

              // Authoritative Wallet Card
              WalletCard(
                balance: wallet?.availableBalance ?? 24850.50,
                maskedAccountNumber:
                    wallet?.maskedAccountNumber ?? 'XXXX XXXX 4589',
              ),
              const SizedBox(height: 20),

              // 4 Quick Actions Row
              Row(
                children: [
                  // Send Money CTA
                  Expanded(
                    child: _buildQuickActionButton(
                      title: 'Send',
                      subtitle: 'Instant',
                      icon: Icons.sync_alt_rounded,
                      isHighlighted: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SendMoneyScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Add Money (UI only)
                  Expanded(
                    child: _buildQuickActionButton(
                      title: 'Add',
                      subtitle: 'Top-up',
                      icon: Icons.add_card_rounded,
                      isHighlighted: false,
                      onTap: _showAddMoneyBottomSheet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Scan QR
                  Expanded(
                    child: _buildQuickActionButton(
                      title: 'Scan QR',
                      subtitle: 'UPI Flow',
                      icon: Icons.qr_code_scanner_rounded,
                      isHighlighted: false,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('UPI Scanner is demo ready'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Transaction History
                  Expanded(
                    child: _buildQuickActionButton(
                      title: 'History',
                      subtitle: 'Statement',
                      icon: Icons.receipt_long_rounded,
                      isHighlighted: false,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TransactionHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Contacts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUICK CONTACTS',
                    style: AppTextStyles.label(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SendMoneyScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Manage >',
                      style: AppTextStyles.label(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildContactAvatar('Rahul', 'RS', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SendMoneyScreen(
                          prefilledName: 'Rahul Sharma',
                          prefilledMobile: '9876543210',
                        ),
                      ),
                    );
                  }),
                  _buildContactAvatar('Priya', 'PS', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SendMoneyScreen(
                          prefilledName: 'Priya Nair',
                          prefilledMobile: '9811233445',
                        ),
                      ),
                    );
                  }),
                  _buildContactAvatar('Amit', 'AK', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SendMoneyScreen(
                          prefilledName: 'Amit Kumar',
                          prefilledMobile: '9765432109',
                        ),
                      ),
                    );
                  }),
                  _buildContactAvatar('BlueTokai', 'BT', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SendMoneyScreen(
                          prefilledName: 'Blue Tokai Coffee',
                          prefilledMobile: '9800012345',
                        ),
                      ),
                    );
                  }),
                  _buildAddContactAvatar(() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SendMoneyScreen(),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Recent Transactions',
                        style: AppTextStyles.headlineSerif(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '5 TODAY',
                          style: AppTextStyles.label(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransactionHistoryScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'View Ledger',
                          style: AppTextStyles.label(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Transactions List (Top 5)
              ...recentTransactions.map((tx) {
                return TransactionItemTile(
                  transaction: tx,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionDetailsScreen(transaction: tx),
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 16),

              // Security Footer
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '256-bit Encrypted Ledger • NPCI / RBI Compliant',
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
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 104,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted ? AppColors.primary : AppColors.outlineLight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFFBE8D8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isHighlighted ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodySans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isHighlighted ? Colors.white : AppColors.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.label(
                fontSize: 10,
                color: isHighlighted
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAvatar(String name, String initials, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF6EFE9),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineLight),
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.bodySans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: AppTextStyles.bodySans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactAvatar(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.outline,
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person_add_alt_rounded,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add',
            style: AppTextStyles.bodySans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.outlineLight)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.account_balance_wallet_rounded, 'Home', 0),
          _buildNavItem(
            Icons.sync_alt_rounded,
            'Send',
            1,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
              );
            },
          ),
          _buildNavItem(
            Icons.receipt_long_rounded,
            'History',
            2,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    VoidCallback? onTap,
  }) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap:
          onTap ??
          () {
            setState(() => _currentNavIndex = index);
          },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.label(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
