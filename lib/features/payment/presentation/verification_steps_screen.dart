import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/outline_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/payment_provider.dart';

class VerificationStepsScreen extends ConsumerWidget {
  const VerificationStepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentProvider);
    final draft = paymentState.draft;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F2), // Light crimson warning background
      appBar: AppBar(
        title: const Text('Scam Intervention'),
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.alertShadow,
                        ),
                        child: const Icon(
                          Icons.front_hand_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'CRITICAL ALERT: STOP!',
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You are likely in the middle of a high-pressure cyber extortion scam.',
                        textAlign: TextAlign.center,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.dangerDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Golden Rules Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '3 Golden Rules to Protect Yourself',
                                  style: AppTypography.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildRuleItem(
                              '1',
                              'No "Digital Arrest" Exists in Law',
                              'Police, Supreme Court, CBI, or ED NEVER conduct arrests or verifications over WhatsApp video calls.',
                            ),
                            const SizedBox(height: 12),
                            _buildRuleItem(
                              '2',
                              'Hang Up the Call Immediately',
                              'Scammers rely on continuous psychological stress. Ending the call will break their control.',
                            ),
                            const SizedBox(height: 12),
                            _buildRuleItem(
                              '3',
                              'Government Accounts are NEVER UPI Handles',
                              'Official verification never requires sending money to ${draft?.recipient.upiId ?? "a personal UPI ID"}.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // National Cyber Crime Helpline Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.support_agent_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Need Help? Call 1930',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Government Cyber Crime Toll-Free Incident Helpline',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.onPrimaryContainer,
                                    ),
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

              // Action Buttons
              PrimaryButton(
                text: 'Cancel Payment & Save My Money',
                icon: Icons.shield_rounded,
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                onPressed: () {
                  ref.read(paymentProvider.notifier).cancelCurrentPayment(
                        'User aborted scam after coercion warning',
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment aborted. Recipient reported as scam.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.go('/home');
                },
              ),
              const SizedBox(height: 10),
              AppOutlineButton(
                text: 'Return Safely to Dashboard',
                textColor: AppColors.textPrimary,
                borderColor: AppColors.border,
                onPressed: () {
                  ref.read(paymentProvider.notifier).reset();
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem(String step, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.dangerLight,
          child: Text(
            step,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.dangerDark,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
