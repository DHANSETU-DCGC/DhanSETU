import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../risk_engine/models/risk_level.dart';
import '../providers/payment_provider.dart';

class FraudAlertScreen extends ConsumerStatefulWidget {
  const FraudAlertScreen({super.key});

  @override
  ConsumerState<FraudAlertScreen> createState() => _FraudAlertScreenState();
}

class _FraudAlertScreenState extends ConsumerState<FraudAlertScreen>
    with SingleTickerProviderStateMixin {
  int _countdownSeconds = 5;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final draft = paymentState.draft;

    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fraud Alert')),
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
        [
          'Active phone call detected during payment attempt',
          'Unverified new recipient account',
          'High risk score (6+ threshold exceeded)',
        ];

    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2), // Light crimson alert wash
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Pulsing Red Warning Shield
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.danger,
                            boxShadow: AppColors.alertShadow,
                          ),
                          child: const Icon(
                            Icons.gpp_bad_rounded,
                            size: 46,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        'PAUSE & VERIFY',
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'High Risk of Potential Scam or Coercion',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.dangerDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const RiskBadge(
                        riskLevel: RiskLevel.high,
                        showIcon: true,
                      ),
                      const SizedBox(height: 20),

                      // High Risk Breakdown Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Risk Engine Score: ${draft.riskAssessment?.score ?? 7} pts',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.dangerLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'CRITICAL',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.borderLight),
                            const SizedBox(height: 12),
                            Text(
                              'Detected Threat Triggers:',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...factors.map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: AppColors.danger,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        f,
                                        style:
                                            AppTypography.bodySmall.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Attempted Transfer',
                                        style: AppTypography.bodySmall,
                                      ),
                                      Text(
                                        draft.recipient.name,
                                        style: AppTypography.titleMedium,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    currencyFormatter.format(draft.amount),
                                    style: AppTypography.headlineSmall.copyWith(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Safety Notice
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_rounded,
                              color: AppColors.dangerDark,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Cybercriminals frequently instruct victims to transfer funds into "safe accounts" during active phone calls.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.dangerDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Emergency Cancel Button (Always available)
              PrimaryButton(
                text: 'Cancel Payment Immediately',
                icon: Icons.cancel_outlined,
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                onPressed: () {
                  ref.read(paymentProvider.notifier).cancelCurrentPayment(
                        'Cancelled by user at High Risk Fraud Alert screen',
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment cancelled & threat report logged.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.go('/home');
                },
              ),
              const SizedBox(height: 10),

              // Pressure Check screen navigation with cooldown timer
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _countdownSeconds == 0
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  side: BorderSide(
                    color: _countdownSeconds == 0
                        ? AppColors.border
                        : AppColors.borderLight,
                  ),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: _countdownSeconds == 0
                    ? () => context.push('/pressure-check')
                    : null,
                child: Text(
                  _countdownSeconds > 0
                      ? 'Mandatory Safety Pause ($_countdownSeconds s)'
                      : 'I still want to review -> Check for Coercion',
                  style: AppTypography.labelLarge.copyWith(
                    color: _countdownSeconds == 0
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
