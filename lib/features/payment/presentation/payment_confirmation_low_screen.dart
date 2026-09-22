import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../risk_engine/models/risk_level.dart';
import '../providers/payment_provider.dart';

class PaymentConfirmationLowScreen extends ConsumerStatefulWidget {
  const PaymentConfirmationLowScreen({super.key});

  @override
  ConsumerState<PaymentConfirmationLowScreen> createState() =>
      _PaymentConfirmationLowScreenState();
}

class _PaymentConfirmationLowScreenState
    extends ConsumerState<PaymentConfirmationLowScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _showUpiPinDialog() {
    _pinController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Enter 4-Digit UPI PIN',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submitting to NPCI Gateway for HDFC Bank •••• 4821',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < _pinController.text.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? AppColors.primary : AppColors.surfaceMuted,
                          border: Border.all(
                            color: isFilled ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  // Quick PIN Entry Keypad
                  _buildModalKeypad(setModalState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalKeypad(StateSetter setModalState) {
    return Column(
      children: [
        for (var r = 0; r < 3; r++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var c = 1; c <= 3; c++)
                _buildKey('${r * 3 + c}', setModalState),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 60, height: 48),
            _buildKey('0', setModalState),
            InkWell(
              onTap: () {
                if (_pinController.text.isNotEmpty) {
                  setModalState(() {
                    _pinController.text = _pinController.text.substring(
                      0,
                      _pinController.text.length - 1,
                    );
                  });
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 60,
                height: 48,
                alignment: Alignment.center,
                child: const Icon(Icons.backspace_outlined, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String val, StateSetter setModalState) {
    return InkWell(
      onTap: () async {
        if (_pinController.text.length < 4) {
          setModalState(() {
            _pinController.text += val;
          });

          if (_pinController.text.length == 4) {
            Navigator.pop(context);
            final success =
                await ref.read(paymentProvider.notifier).executePayment();
            if (success && mounted) {
              context.go('/payment-success');
            }
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          val,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final draft = paymentState.draft;

    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirm Payment')),
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
        title: const Text('Payment Confirmation'),
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
                    children: [
                      // Low Risk Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.successDark,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Safe & Verified Transaction',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.successDark,
                                    ),
                                  ),
                                  Text(
                                    'Recipient trust score is 99/100 with zero risk anomalies.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.successDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const RiskBadge(
                              riskLevel: RiskLevel.low,
                              compact: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Card with details
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(
                                draft.recipient.initials,
                                style: AppTypography.headlineSmall.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              draft.recipient.name,
                              style: AppTypography.titleLarge,
                            ),
                            Text(
                              draft.recipient.upiId,
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Paying',
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormatter.format(draft.amount),
                              style: AppTypography.amountDisplay.copyWith(
                                color: AppColors.primary,
                                fontSize: 34,
                              ),
                            ),
                            if (draft.note.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Note: ${draft.note}',
                                  style: AppTypography.bodySmall,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            // Bank account source
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_rounded,
                                    color: AppColors.primaryDark,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Debiting From',
                                          style: AppTypography.bodySmall
                                              .copyWith(fontSize: 11),
                                        ),
                                        Text(
                                          draft.selectedBank,
                                          style: AppTypography.titleMedium
                                              .copyWith(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              PrimaryButton(
                text: 'Pay ${currencyFormatter.format(draft.amount)} Securely',
                icon: Icons.lock_outline_rounded,
                isLoading: paymentState.isProcessing,
                onPressed: _showUpiPinDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
