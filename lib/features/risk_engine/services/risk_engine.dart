import '../models/risk_assessment.dart';
import '../models/risk_level.dart';
import '../models/risk_signals.dart';

abstract class IRiskEngine {
  RiskAssessment calculate(RiskSignals signals);
}

class RiskEngine implements IRiskEngine {
  const RiskEngine();

  @override
  RiskAssessment calculate(RiskSignals signals) {
    int score = 0;
    final List<String> factors = [];

    // Rule 1: New recipient (+2)
    if (signals.isNewRecipient) {
      score += 2;
      factors.add('First-time transfer to an unverified recipient (+2 pts)');
    }

    // Rule 2: Amount > 3x average (+3)
    if (signals.isAmountExceedingThreshold) {
      score += 3;
      factors.add(
        'Payment amount is significantly higher than your typical average (+3 pts)',
      );
    }

    // Rule 3: Late night transaction (+1)
    if (signals.isLateNight) {
      score += 1;
      factors.add('Unusual late-night transaction hours (+1 pt)');
    }

    // Rule 4: Active phone call detected (+2)
    if (signals.isOnActiveCall) {
      score += 2;
      factors.add(
        'Active phone call in progress during transaction (High correlation with social engineering scams) (+2 pts)',
      );
    }

    // Rule 5: High velocity (+2)
    if (signals.transactionVelocity > 3) {
      score += 2;
      factors.add(
        'Elevated transaction velocity (${signals.transactionVelocity} payments in 1 hr) (+2 pts)',
      );
    }

    // Rule 6: Recent contact added (+1)
    if (signals.recentContactAdded) {
      score += 1;
      factors.add('Recipient was added to contacts less than 24 hours ago (+1 pt)');
    }

    // Determine Risk Level based on thresholds
    // 0-2 = low, 3-5 = medium, 6+ = high
    final RiskLevel level;
    if (score >= 6) {
      level = RiskLevel.high;
    } else if (score >= 3) {
      level = RiskLevel.medium;
    } else {
      level = RiskLevel.low;
    }

    if (factors.isEmpty) {
      factors.add('Known recipient and normal velocity profile');
    }

    return RiskAssessment(
      score: score,
      level: level,
      factors: factors,
      signals: signals,
      calculatedAt: DateTime.now(),
    );
  }
}
