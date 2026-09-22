import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/outline_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/payment_provider.dart';

class PaymentInterceptionScreen extends ConsumerStatefulWidget {
  const PaymentInterceptionScreen({super.key});

  @override
  ConsumerState<PaymentInterceptionScreen> createState() =>
      _PaymentInterceptionScreenState();
}

class _PaymentInterceptionScreenState
    extends ConsumerState<PaymentInterceptionScreen> {
  bool _knowsPersonally = false;
  bool _notForLegalCase = false;
  bool _acceptsIrreversible = false;

  bool get _allChecked =>
      _knowsPersonally && _notForLegalCase && _acceptsIrreversible;

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final draft = paymentState.draft;

    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Interception Alert')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Return to Home'),
          ),
        ),
      );
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: draft.amount % 1 == 0 ? 0 : 2,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Interception'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header warning
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.security_update_warning_rounded,
                              color: AppColors.warningDark,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Final Interception: Name & Identity Verification',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.warningDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        'Re-Verify Payee Credentials',
                        style: AppTypography.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Because this transaction triggered high risk thresholds, our sentinel requires explicit legal confirmation before releasing funds.',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 16),

                      // Payee details comparison
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Recipient Name',
                              draft.recipient.name,
                              Icons.person_outline_rounded,
                            ),
                            const Divider(height: 20),
                            _buildDetailRow(
                              'UPI Handle',
                              draft.recipient.upiId,
                              Icons.alternate_email_rounded,
                            ),
                            const Divider(height: 20),
                            _buildDetailRow(
                              'Destination Bank',
                              draft.recipient.bankName,
                              Icons.account_balance_rounded,
                            ),
                            const Divider(height: 20),
                            _buildDetailRow(
                              'Amount to Transfer',
                              currencyFormatter.format(draft.amount),
                              Icons.currency_rupee_rounded,
                              isHighlighted: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Mandatory Security Checkpoints',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 8),

                      // Checkbox 1
                      _buildCheckTile(
                        value: _knowsPersonally,
                        onChanged: (v) =>
                            setState(() => _knowsPersonally = v ?? false),
                        title:
                            'I have personally met or spoke with this individual outside this payment session.',
                      ),
                      const SizedBox(height: 8),

                      // Checkbox 2
                      _buildCheckTile(
                        value: _notForLegalCase,
                        onChanged: (v) =>
                            setState(() => _notForLegalCase = v ?? false),
                        title:
                            'This payment is NOT for legal clearance, lottery prize claims, customs duty, or job processing.',
                      ),
                      const SizedBox(height: 8),

                      // Checkbox 3
                      _buildCheckTile(
                        value: _acceptsIrreversible,
                        onChanged: (v) =>
                            setState(() => _acceptsIrreversible = v ?? false),
                        title:
                            'I understand UPI transactions settle instantly and cannot be recalled once sent.',
                      ),
                    ],
                  ),
                ),
              ),

              PrimaryButton(
                text: 'Continue with Confirmation',
                backgroundColor:
                    _allChecked ? AppColors.primary : AppColors.border,
                foregroundColor:
                    _allChecked ? Colors.white : AppColors.textTertiary,
                onPressed: _allChecked
                    ? () {
                        context.push('/confirm-medium');
                      }
                    : null,
              ),
              const SizedBox(height: 10),
              AppOutlineButton(
                text: 'Cancel Payment & Exit',
                textColor: AppColors.textSecondary,
                borderColor: AppColors.border,
                onPressed: () {
                  ref.read(paymentProvider.notifier).cancelCurrentPayment(
                        'Cancelled by user at Interception screen',
                      );
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? AppColors.primary : AppColors.border,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Text(
          title,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {bool isHighlighted = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.bodySmall),
        const Spacer(),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontSize: isHighlighted ? 16 : 14,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: isHighlighted ? AppColors.primaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
