import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum StatusType {
  success,
  warning,
  danger,
  neutral,
  info;

  Color get color {
    switch (this) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.danger:
        return AppColors.danger;
      case StatusType.neutral:
        return AppColors.textSecondary;
      case StatusType.info:
        return AppColors.primary;
    }
  }

  Color get containerColor {
    switch (this) {
      case StatusType.success:
        return AppColors.successLight;
      case StatusType.warning:
        return AppColors.warningLight;
      case StatusType.danger:
        return AppColors.dangerLight;
      case StatusType.neutral:
        return AppColors.surfaceMuted;
      case StatusType.info:
        return AppColors.primaryContainer;
    }
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  final IconData? icon;
  final bool compact;

  const StatusChip({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: type.containerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: compact ? 11 : 13,
              color: type.color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: type.color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
