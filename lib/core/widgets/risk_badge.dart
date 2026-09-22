import 'package:flutter/material.dart';
import '../../features/risk_engine/models/risk_level.dart';
import '../theme/app_typography.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel riskLevel;
  final bool compact;
  final bool showIcon;

  const RiskBadge({
    super.key,
    required this.riskLevel,
    this.compact = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: riskLevel.containerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: riskLevel.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              riskLevel.icon,
              size: compact ? 12 : 15,
              color: riskLevel.color,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            riskLevel.displayName,
            style: AppTypography.labelSmall.copyWith(
              color: riskLevel.color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
