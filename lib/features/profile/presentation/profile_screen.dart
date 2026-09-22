import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // User Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        'AS',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      authState.userName,
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authState.userUpiId,
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      authState.userPhone,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            size: 14,
                            color: AppColors.onPrimaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'NPCI Verified Identity',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Linked Accounts Section
              _buildSectionHeader('Linked Bank Accounts'),
              _buildBankCard(
                'HDFC Bank',
                'Account •••• 4821',
                'Default for Transfers',
                Icons.account_balance_rounded,
                isPrimary: true,
              ),
              const SizedBox(height: 8),
              _buildBankCard(
                'State Bank of India',
                'Account •••• 1092',
                'Secondary Account',
                Icons.account_balance_rounded,
                isPrimary: false,
              ),

              const SizedBox(height: 20),

              // Security & Limits Section
              _buildSectionHeader('Security & Fraud Safeguards'),
              _buildMenuTile(
                icon: Icons.shield_outlined,
                title: 'Security Center',
                subtitle: 'Manage active protection shields & fraud logs',
                onTap: () => context.push('/security-center'),
              ),
              const SizedBox(height: 8),
              _buildMenuTile(
                icon: Icons.pin_rounded,
                title: 'Change UPI PIN',
                subtitle: 'Update your 4-digit bank authorization PIN',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('UPI PIN management is demo verified.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildMenuTile(
                icon: Icons.speed_rounded,
                title: 'Transaction Limits',
                subtitle: 'Daily cap: ₹50,000 • Per-transaction cap: ₹25,000',
                onTap: () {},
              ),

              const SizedBox(height: 28),

              // Logout Button
              PrimaryButton(
                text: 'Log Out of SecurePay',
                icon: Icons.logout_rounded,
                backgroundColor: AppColors.surfaceMuted,
                foregroundColor: AppColors.danger,
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBankCard(
    String bankName,
    String account,
    String badge,
    IconData icon, {
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              color: isPrimary
                  ? AppColors.primaryContainer
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isPrimary
                  ? AppColors.onPrimaryContainer
                  : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bankName, style: AppTypography.titleMedium),
                Text(account, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.successLight
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: AppTypography.labelSmall.copyWith(
                color: isPrimary
                    ? AppColors.successDark
                    : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
