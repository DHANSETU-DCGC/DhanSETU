import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/trust_signal_tile.dart';
import '../../risk_engine/models/risk_level.dart';
import '../providers/payment_provider.dart';

class RecipientProfilingScreen extends ConsumerWidget {
  const RecipientProfilingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentProvider);
    final draft = paymentState.draft;

    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profiling')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No payment draft selected'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/send-money'),
                child: const Text('Select Recipient'),
              ),
            ],
          ),
        ),
      );
    }

    final recipient = draft.recipient;
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: draft.amount % 1 == 0 ? 0 : 2,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recipient Trust Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Summary Card
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
                      radius: 32,
                      backgroundColor: recipient.isNewRecipient
                          ? AppColors.dangerLight
                          : AppColors.primaryContainer,
                      child: Text(
                        recipient.initials,
                        style: AppTypography.headlineMedium.copyWith(
                          color: recipient.isNewRecipient
                              ? AppColors.dangerDark
                              : AppColors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          recipient.name,
                          style: AppTypography.headlineSmall,
                        ),
                        if (recipient.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipient.upiId,
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment Amount', style: AppTypography.bodySmall),
                          Text(
                            currencyFormatter.format(draft.amount),
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Trust & Security Signals',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 12),

              // Trust Score Meter Tile
              TrustSignalTile(
                title: 'Trust Score: ${recipient.trustScore}/100',
                subtitle: recipient.trustScore >= 80
                    ? 'High reputation index across NPCI banking network'
                    : 'Low score: Recipient has anomalous activity or fraud flags',
                icon: Icons.shield_rounded,
                statusType: recipient.trustScore >= 80
                    ? StatusType.success
                    : (recipient.trustScore >= 50
                        ? StatusType.warning
                        : StatusType.danger),
                badgeText: recipient.trustScore >= 80 ? 'HIGH TRUST' : 'ELEVATED RISK',
              ),
              const SizedBox(height: 10),

              // Account Age Signal
              TrustSignalTile(
                title: 'UPI History & Account Age',
                subtitle: recipient.formattedAccountAge,
                icon: Icons.history_rounded,
                statusType: recipient.accountAgeDays > 180
                    ? StatusType.success
                    : (recipient.accountAgeDays > 30
                        ? StatusType.warning
                        : StatusType.danger),
                badgeText: recipient.accountAgeDays > 180 ? 'MATURE' : 'NEW ACCOUNT',
              ),
              const SizedBox(height: 10),

              // Fraud Reports
              TrustSignalTile(
                title: 'Scam & Impersonation Complaints',
                subtitle: recipient.fraudReportsCount == 0
                    ? '0 reports filed against this UPI ID'
                    : '${recipient.fraudReportsCount} cybercrime complaints lodged against this UPI handle',
                icon: Icons.report_problem_rounded,
                statusType: recipient.fraudReportsCount == 0
                    ? StatusType.success
                    : StatusType.danger,
                badgeText: recipient.fraudReportsCount == 0 ? 'CLEAN' : 'FLAGGED',
              ),
              const SizedBox(height: 10),

              // Phone Call Status Signal
              TrustSignalTile(
                title: 'Call Telemetry Signal',
                subtitle: draft.riskSignals.isOnActiveCall
                    ? 'Active telephone call in progress (Scam vulnerability)'
                    : 'No external call active on device',
                icon: Icons.phone_in_talk_rounded,
                statusType: draft.riskSignals.isOnActiveCall
                    ? StatusType.danger
                    : StatusType.success,
                badgeText: draft.riskSignals.isOnActiveCall ? 'CALL ACTIVE' : 'SECURE',
              ),

              const SizedBox(height: 32),

              // Primary Action
              PrimaryButton(
                text: 'Proceed with Secure Check',
                icon: Icons.security_rounded,
                onPressed: () {
                  final riskLevel =
                      ref.read(paymentProvider.notifier).evaluateCurrentRisk();

                  // Conditional navigation based on calculated Risk Level
                  switch (riskLevel) {
                    case RiskLevel.low:
                      context.push('/confirm-low');
                      break;
                    case RiskLevel.medium:
                      context.push('/confirm-medium');
                      break;
                    case RiskLevel.high:
                      context.push('/fraud-alert');
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
