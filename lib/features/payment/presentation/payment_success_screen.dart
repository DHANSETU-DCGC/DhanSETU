import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/outline_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../risk_engine/models/risk_level.dart';
import '../providers/payment_provider.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final tx = paymentState.completedTransaction;

    final amountFormatted = tx != null
        ? NumberFormat.currency(
            locale: 'en_IN',
            symbol: '₹',
            decimalDigits: tx.amount % 1 == 0 ? 0 : 2,
          ).format(tx.amount)
        : '₹0.00';

    final dateFormatted = tx != null
        ? DateFormat('dd MMMM yyyy, hh:mm a').format(tx.timestamp)
        : DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.now());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ref.read(paymentProvider.notifier).reset();
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const Spacer(),

                // Animated Checkmark Circle
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Payment Successful!',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amountFormatted,
                  style: AppTypography.amountDisplay.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 38,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transferred to ${tx?.recipientName ?? "Recipient"}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  tx?.recipientUpiId ?? '',
                  style: AppTypography.bodySmall,
                ),

                const SizedBox(height: 28),

                // Receipt Breakdown Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('UPI Ref ID',
                          tx?.bankReference ?? 'UPI/84920194/48192'),
                      const Divider(height: 20),
                      _buildReceiptRow('Date & Time', dateFormatted),
                      const Divider(height: 20),
                      _buildReceiptRow(
                          'Payment Mode', 'UPI Instant Net-Banking'),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Risk Engine Clearance',
                              style: AppTypography.bodySmall),
                          RiskBadge(
                            riskLevel: tx?.riskLevel ?? RiskLevel.low,
                            compact: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Shield verification note
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: AppColors.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Secured & Recorded by SecurePay Sentinel',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Buttons
                PrimaryButton(
                  text: 'Back to Dashboard',
                  onPressed: () {
                    ref.read(paymentProvider.notifier).reset();
                    context.go('/home');
                  },
                ),
                const SizedBox(height: 10),
                AppOutlineButton(
                  text: 'Share Payment Receipt',
                  icon: Icons.share_outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment receipt saved to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
