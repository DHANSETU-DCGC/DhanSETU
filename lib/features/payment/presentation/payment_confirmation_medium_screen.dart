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

class PaymentConfirmationMediumScreen extends ConsumerStatefulWidget {
  const PaymentConfirmationMediumScreen({super.key});

  @override
  ConsumerState<PaymentConfirmationMediumScreen> createState() =>
      _PaymentConfirmationMediumScreenState();
}

class _PaymentConfirmationMediumScreenState
    extends ConsumerState<PaymentConfirmationMediumScreen> {
  bool _hasAcknowledged = false;
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
                    'Authorizing Medium-Risk Transfer of ₹${ref.read(paymentProvider).draft?.amount ?? 0}',
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
                          color: isFilled ? AppColors.warning : AppColors.surfaceMuted,
                          border: Border.all(
                            color: isFilled ? AppColors.warning : AppColors.border,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
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
        appBar: AppBar(title: const Text('Review Warning')),
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

    final factors = draft.riskAssessment?.factors ??
        ['Amount exceeds normal spending profile'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Security Review'),
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
                      // Amber Warning Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.warningDark,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Caution: Elevated Transaction Risk',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.warningDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const RiskBadge(
                                  riskLevel: RiskLevel.medium,
                                  compact: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Our fraud shield detected unusual patterns in this payment. Please review before authorizing:',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.warningDark,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...factors.map((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ',
                                          style: TextStyle(
                                              color: AppColors.warningDark,
                                              fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: Text(
                                          f,
                                          style:
                                              AppTypography.bodySmall.copyWith(
                                            color: AppColors.warningDark,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Payment summary card
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
                              radius: 28,
                              backgroundColor: AppColors.warningLight,
                              child: Text(
                                draft.recipient.initials,
                                style: AppTypography.titleLarge.copyWith(
                                  color: AppColors.warningDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
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
                            Text('Amount to Debit', style: AppTypography.bodySmall),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormatter.format(draft.amount),
                              style: AppTypography.amountDisplay.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      draft.selectedBank,
                                      style: AppTypography.titleMedium
                                          .copyWith(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Friction Checkbox
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _hasAcknowledged
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: _hasAcknowledged,
                          onChanged: (val) =>
                              setState(() => _hasAcknowledged = val ?? false),
                          title: Text(
                            'I have verified the payee identity and explicitly authorize this transfer amount.',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              PrimaryButton(
                text: 'Confirm & Enter UPI PIN',
                backgroundColor:
                    _hasAcknowledged ? AppColors.primary : AppColors.border,
                foregroundColor:
                    _hasAcknowledged ? Colors.white : AppColors.textTertiary,
                onPressed: _hasAcknowledged ? _showUpiPinDialog : null,
              ),
              const SizedBox(height: 10),
              AppOutlineButton(
                text: 'Cancel & Return Home',
                textColor: AppColors.textSecondary,
                borderColor: AppColors.border,
                onPressed: () {
                  ref
                      .read(paymentProvider.notifier)
                      .cancelCurrentPayment('Cancelled by user at warning screen');
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
