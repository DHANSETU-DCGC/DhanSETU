import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum RiskLevel {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.low:
        return AppColors.success;
      case RiskLevel.medium:
        return AppColors.warning;
      case RiskLevel.high:
        return AppColors.danger;
    }
  }

  Color get containerColor {
    switch (this) {
      case RiskLevel.low:
        return AppColors.successLight;
      case RiskLevel.medium:
        return AppColors.warningLight;
      case RiskLevel.high:
        return AppColors.dangerLight;
    }
  }

  IconData get icon {
    switch (this) {
      case RiskLevel.low:
        return Icons.verified_user_rounded;
      case RiskLevel.medium:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
        return Icons.shield_rounded;
    }
  }

  String get shortDescription {
    switch (this) {
      case RiskLevel.low:
        return 'Verified & Safe';
      case RiskLevel.medium:
        return 'Elevated Warning';
      case RiskLevel.high:
        return 'Fraud Alert Detected';
    }
  }
}
