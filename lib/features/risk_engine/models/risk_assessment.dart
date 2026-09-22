import 'risk_level.dart';
import 'risk_signals.dart';

class RiskAssessment {
  final int score;
  final RiskLevel level;
  final List<String> factors;
  final RiskSignals signals;
  final DateTime calculatedAt;

  const RiskAssessment({
    required this.score,
    required this.level,
    required this.factors,
    required this.signals,
    required this.calculatedAt,
  });

  bool get isHighRisk => level == RiskLevel.high;
  bool get isMediumRisk => level == RiskLevel.medium;
  bool get isLowRisk => level == RiskLevel.low;

  factory RiskAssessment.initial() {
    final now = DateTime.now();
    return RiskAssessment(
      score: 0,
      level: RiskLevel.low,
      factors: const ['Safe trusted transaction profile'],
      signals: RiskSignals(timeOfDay: now),
      calculatedAt: now,
    );
  }
}
