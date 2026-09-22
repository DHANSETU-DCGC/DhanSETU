import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'status_chip.dart';

class TrustSignalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final StatusType statusType;
  final String? badgeText;
  final Widget? trailing;

  const TrustSignalTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.statusType = StatusType.neutral,
    this.badgeText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusType.containerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: statusType.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (badgeText != null)
                      StatusChip(
                        label: badgeText!,
                        type: statusType,
                        compact: true,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
