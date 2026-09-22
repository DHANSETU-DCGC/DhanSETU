import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/outline_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/payment_provider.dart';

class PressureCheckScreen extends ConsumerWidget {
  const PressureCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentProvider);
    final draft = paymentState.draft;

    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Coercion Check')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Return to Home'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Safety Audit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.psychology_alt_rounded,
                              color: AppColors.warningDark,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Coercion & Social Engineering Screen',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.warningDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Was someone pressuring or instructing you?',
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Over 85% of high-risk UPI frauds happen when the victim is being actively coerced over a phone call or WhatsApp message.',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 20),

                      // Common Coercion Tactics Card
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
                            Text(
                              'Common Fraud Tactics to Watch Out For:',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTacticItem(
                              Icons.local_police_outlined,
                              'Fake Authority / Digital Arrest',
                              'Caller claims to be Police, CBI, ED, or Customs threatening arrest unless money is transferred.',
                            ),
                            const SizedBox(height: 12),
                            _buildTacticItem(
                              Icons.power_off_outlined,
                              'Urgent Service Disconnection',
                              'Threats that electricity, courier, or SIM card will be deactivated within hours.',
                            ),
                            const SizedBox(height: 12),
                            _buildTacticItem(
                              Icons.screen_share_outlined,
                              'Remote Screen Sharing',
                              'Instructions to install AnyDesk, TeamViewer, or RustDesk on your device.',
                            ),
                            const SizedBox(height: 12),
                            _buildTacticItem(
                              Icons.lock_clock_outlined,
                              'Secretive Pressure',
                              'Caller insists you must not speak to family members or hang up the call.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Option YES: User is being pressured -> Strong Warning & Cancel flow
              PrimaryButton(
                text: 'YES — Someone is instructing me',
                icon: Icons.warning_rounded,
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                onPressed: () {
                  ref
                      .read(paymentProvider.notifier)
                      .setPressureCheckResponse(true);
                  context.push('/verification-steps');
                },
              ),
              const SizedBox(height: 12),

              // Option NO: Voluntary -> Re-check payment interception flow
              AppOutlineButton(
                text: 'NO — I know this person voluntarily',
                icon: Icons.check_circle_outline_rounded,
                textColor: AppColors.textPrimary,
                borderColor: AppColors.border,
                onPressed: () {
                  ref
                      .read(paymentProvider.notifier)
                      .setPressureCheckResponse(false);
                  context.push('/payment-interception');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTacticItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryDark, size: 18),
        ),
        const SizedBox(width: 12),
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
                desc,
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
