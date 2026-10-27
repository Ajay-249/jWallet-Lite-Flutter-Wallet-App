import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../providers/wallet_state.dart';
import '../widgets/transaction_item_tile.dart';
import 'send_money_screen.dart';
import 'transaction_details_screen.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  int _currentNavIndex = 2; // History is index 2
  String _selectedDateRange = 'All Time'; // 'All Time', 'Today', 'This Week'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<TransactionModel>> _groupTransactions(
      List<TransactionModel> list) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (var tx in list) {
      final header = DateFormatter.formatDateHeader(tx.createdAt);
      grouped.putIfAbsent(header, () => []).add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);
    final activeFilter = state.transactionFilter;
    final transactions = state.filteredTransactions;

    // Calculate metrics
    double totalSent = 0;
    int sentCount = 0;
    double totalReceived = 0;

    for (var tx in state.transactions) {
      if (tx.isCredit) {
        totalReceived += tx.amount;
      } else {
        totalSent += tx.amount;
        sentCount++;
      }
    }
    final netAmount = totalReceived - totalSent;

    final dateFilteredTransactions = transactions.where((tx) {
      if (_selectedDateRange == 'Today') {
        final now = DateTime.now();
        return tx.createdAt.year == now.year &&
            tx.createdAt.month == now.month &&
            tx.createdAt.day == now.day;
      } else if (_selectedDateRange == 'This Week') {
        final now = DateTime.now();
        return now.difference(tx.createdAt).inDays <= 7;
      }
      return true;
    }).toList();

    final grouped = _groupTransactions(dateFilteredTransactions);

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
              'Ledger History',
              style: AppTextStyles.headlineSerif(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                const SizedBox(width: 4),
                Text(
                  'REALTIME SYNC ACTIVE',
                  style: AppTextStyles.label(
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),

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
              // Dark Summary Metric Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'LEDGER METRIC',
                              style: AppTextStyles.label(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFB5A89E),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'May 2024',
                                style: AppTextStyles.label(
                                  fontSize: 9,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Detailed Audit >',
                          style: AppTextStyles.label(
                            fontSize: 11,
                            color: const Color(0xFFF0DDD0),
                            fontWeight: FontWeight.w600,
                          ),
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
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.north_east_rounded,
                                      size: 13,
                                      color: Color(0xFFE57373),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Total Sent',
                                      style: AppTextStyles.label(
                                        fontSize: 10,
                                        color: const Color(0xFFD6C8BE),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.format(totalSent),
                                  style: AppTextStyles.bodySans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$sentCount Transactions',
                                  style: AppTextStyles.label(
                                    fontSize: 9,
                                    color: const Color(0xFFB5A89E),
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
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.south_west_rounded,
                                      size: 13,
                                      color: Color(0xFF81C784),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Total Received',
                                      style: AppTextStyles.label(
                                        fontSize: 10,
                                        color: const Color(0xFFD6C8BE),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.format(totalReceived),
                                  style: AppTextStyles.bodySans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+${CurrencyFormatter.format(netAmount)} Net',
                                  style: AppTextStyles.label(
                                    fontSize: 9,
                                    color: const Color(0xFF81C784),
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

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(walletProvider.notifier).setSearchQuery(val);
                  },
                  style: AppTextStyles.bodySans(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by Ref ID, Payee, Merchant...',
                    hintStyle: AppTextStyles.bodySans(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(walletProvider.notifier)
                                  .setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              // Date Range Filter Chips (Bonus Feature)
              Row(
                children: [
                  _buildDateChip('All Time'),
                  const SizedBox(width: 8),
                  _buildDateChip('Today'),
                  const SizedBox(width: 8),
                  _buildDateChip('This Week'),
                ],
              ),
              const SizedBox(height: 10),

              // Type Selector & Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All (${state.transactions.length})',
                      isSelected: activeFilter == 'ALL',
                      onTap: () =>
                          ref.read(walletProvider.notifier).setFilter('ALL'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Debit (Sent)',
                      isSelected: activeFilter == 'DEBIT',
                      onTap: () =>
                          ref.read(walletProvider.notifier).setFilter('DEBIT'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Credit (Received)',
                      isSelected: activeFilter == 'CREDIT',
                      onTap: () =>
                          ref.read(walletProvider.notifier).setFilter('CREDIT'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Grouped Transaction List
              if (transactions.isEmpty) ...[
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_outlined,
                          size: 36,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Transactions Found',
                        style: AppTextStyles.headlineSerif(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try adjusting your search query or filter chips.',
                        style: AppTextStyles.bodySans(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ] else ...[
                ...grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: AppTextStyles.headlineSerif(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              '${entry.value.length} entries',
                              style: AppTextStyles.label(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...entry.value.map((tx) {
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
                      const SizedBox(height: 6),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.onSurface,
          ),
        ),
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
          _buildNavItem(Icons.account_balance_wallet_rounded, 'Home', 0,
              onTap: () => Navigator.pop(context)),
          _buildNavItem(Icons.sync_alt_rounded, 'Send', 1, onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
            );
          }),
          _buildNavItem(Icons.receipt_long_rounded, 'History', 2),
          _buildNavItem(Icons.person_outline_rounded, 'Profile', 3, onTap: () {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {VoidCallback? onTap}) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: onTap ?? () => setState(() => _currentNavIndex = index),
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

  Widget _buildDateChip(String label) {
    final isSelected = _selectedDateRange == label;
    return InkWell(
      onTap: () => setState(() => _selectedDateRange = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBE8D8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.label(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
