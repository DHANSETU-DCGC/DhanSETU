import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../risk_engine/models/risk_level.dart';
import '../models/transaction_model.dart';
import '../providers/history_provider.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTransactionDetails(TransactionModel tx) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: tx.amount % 1 == 0 ? 0 : 2,
    );
    final dateFormatter = DateFormat('dd MMMM yyyy, hh:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
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
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transaction Details', style: AppTypography.headlineSmall),
                  RiskBadge(riskLevel: tx.riskLevel, compact: true),
                ],
              ),
              const SizedBox(height: 16),

              // Amount & Recipient
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      currencyFormatter.format(tx.amount),
                      style: AppTypography.headlineMedium.copyWith(
                        color: tx.status == TransactionStatus.blocked
                            ? AppColors.danger
                            : AppColors.primaryDark,
                        fontWeight: FontWeight.w800,
                        decoration: tx.status == TransactionStatus.blocked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.recipientName,
                      style: AppTypography.titleMedium,
                    ),
                    Text(tx.recipientUpiId, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildDetailRow('Status', tx.status.displayName),
              const Divider(height: 16),
              _buildDetailRow('Timestamp', dateFormatter.format(tx.timestamp)),
              const Divider(height: 16),
              _buildDetailRow(
                'Reference ID',
                tx.bankReference ?? 'UPI/N/A',
              ),
              if (tx.note != null && tx.note!.isNotEmpty) ...[
                const Divider(height: 16),
                _buildDetailRow('Note', tx.note!),
              ],

              const SizedBox(height: 16),
              Text(
                'Risk Sentinel Signals at Payment Time:',
                style: AppTypography.titleMedium.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 8),
              if (tx.riskReasons.isEmpty)
                Text(
                  '• Verified payee with zero threat anomalies detected',
                  style: AppTypography.bodySmall,
                )
              else
                ...tx.riskReasons.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $r', style: AppTypography.bodySmall),
                  ),
                ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.titleMedium.copyWith(fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final transactions = historyState.filteredTransactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(historyProvider.notifier).setSearchQuery(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search transactions by name or UPI handle',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(historyProvider.notifier)
                                .setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Risk Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All Activity',
                    isSelected: historyState.selectedRiskFilter == null,
                    onTap: () =>
                        ref.read(historyProvider.notifier).setFilter(null),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Low Risk',
                    isSelected:
                        historyState.selectedRiskFilter == RiskLevel.low,
                    color: AppColors.success,
                    onTap: () => ref
                        .read(historyProvider.notifier)
                        .setFilter(RiskLevel.low),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Medium Risk',
                    isSelected:
                        historyState.selectedRiskFilter == RiskLevel.medium,
                    color: AppColors.warning,
                    onTap: () => ref
                        .read(historyProvider.notifier)
                        .setFilter(RiskLevel.medium),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'High Risk / Blocked',
                    isSelected:
                        historyState.selectedRiskFilter == RiskLevel.high,
                    color: AppColors.danger,
                    onTap: () => ref
                        .read(historyProvider.notifier)
                        .setFilter(RiskLevel.high),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Transactions list
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions found',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return TransactionTile(
                          transaction: tx,
                          onTap: () => _showTransactionDetails(tx),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final activeColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? activeColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
