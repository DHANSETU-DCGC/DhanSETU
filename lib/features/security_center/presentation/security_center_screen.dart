import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/security_provider.dart';

class SecurityCenterScreen extends ConsumerWidget {
  const SecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Security Center'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Score Hero Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: securityState.overallScore / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '${securityState.overallScore}%',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shield_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'REAL-TIME SENTINEL ACTIVE',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'System Health: Protected',
                            style: AppTypography.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${securityState.totalThreatsNeutralized} potential fraud attempts intercepted this month.',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text('Active Protection Shields', style: AppTypography.titleLarge),
              const SizedBox(height: 12),

              // Shield 1: Call Impersonation Interceptor
              _buildShieldTile(
                title: 'Call Impersonation Guard',
                subtitle:
                    'Alerts if an active phone call is detected while transferring money.',
                icon: Icons.phone_in_talk_rounded,
                isActive: securityState.isCallGuardActive,
                onChanged: (_) =>
                    ref.read(securityProvider.notifier).toggleCallGuard(),
              ),
              const SizedBox(height: 8),

              // Shield 2: AI Coercion Detector
              _buildShieldTile(
                title: 'Pressure & Coercion Audit',
                subtitle:
                    'Monitors velocity and recipient flags for digital arrest scam patterns.',
                icon: Icons.psychology_alt_rounded,
                isActive: securityState.isAiCoercionDetectorActive,
                onChanged: (_) =>
                    ref.read(securityProvider.notifier).toggleAiCoercion(),
              ),
              const SizedBox(height: 8),

              // Shield 3: Velocity Limiter
              _buildShieldTile(
                title: 'High-Velocity Drain Limiter',
                subtitle:
                    'Prevents rapid consecutive transfers to new unverified UPI accounts.',
                icon: Icons.speed_rounded,
                isActive: securityState.isVelocityLimiterActive,
                onChanged: (_) =>
                    ref.read(securityProvider.notifier).toggleVelocity(),
              ),
              const SizedBox(height: 8),

              // Shield 4: Biometric Payment Shield
              _buildShieldTile(
                title: 'Biometric App Authentication',
                subtitle:
                    'Enforces Fingerprint / Face ID for session and high-value payments.',
                icon: Icons.fingerprint_rounded,
                isActive: securityState.isBiometricLockActive,
                onChanged: (_) =>
                    ref.read(securityProvider.notifier).toggleBiometrics(),
              ),

              const SizedBox(height: 24),

              // National Cyber Crime Helpline Card
              Container(
                padding: const EdgeInsets.all(16),
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: AppColors.primaryDark,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'National Cyber Crime Helpline',
                                style: AppTypography.titleMedium,
                              ),
                              Text(
                                'Ministry of Home Affairs (MHA), Govt. of India',
                                style: AppTypography.bodySmall.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Dial 1930 immediately if you were tricked into sending funds or suspect identity theft.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.call_rounded, size: 16),
                            label: const Text('Call 1930'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dialing 1930 Cyber Helpline...'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.public_rounded, size: 16),
                            label: const Text('Visit Portal'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Opening cybercrime.gov.in portal...'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Demo Sandbox Launcher
              PrimaryButton(
                text: 'Launch Risk Simulator Flow',
                icon: Icons.play_arrow_rounded,
                onPressed: () => context.go('/send-money'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShieldTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryContainer
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? AppColors.onPrimaryContainer
                  : AppColors.textTertiary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
