import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/history/models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'risk_badge.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: transaction.amount % 1 == 0 ? 0 : 2,
    );

    final dateFormatter = DateFormat('dd MMM, hh:mm a');

    final initials = transaction.recipientName.isNotEmpty
        ? transaction.recipientName
            .trim()
            .split(' ')
            .take(2)
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .join()
        : 'U';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                initials,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.recipientName,
                    style: AppTypography.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormatter.format(transaction.timestamp),
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(transaction.amount),
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: transaction.status == TransactionStatus.blocked
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                    decoration: transaction.status == TransactionStatus.blocked
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                RiskBadge(
                  riskLevel: transaction.riskLevel,
                  compact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
