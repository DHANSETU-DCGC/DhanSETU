import 'package:flutter_test/flutter_test.dart';
import 'package:secure_pay/features/risk_engine/models/risk_level.dart';
import 'package:secure_pay/features/risk_engine/models/risk_signals.dart';
import 'package:secure_pay/features/risk_engine/services/risk_engine.dart';

void main() {
  late RiskEngine engine;

  setUp(() {
    engine = const RiskEngine();
  });

  group('RiskEngine Unit Tests', () {
    test('Low Risk for familiar payee with standard amount during daytime', () {
      final signals = RiskSignals(
        isNewRecipient: false,
        amount: 500.0,
        avgTransactionAmount: 2500.0,
        timeOfDay: DateTime(2026, 9, 23, 14, 0), // 2:00 PM
        deviceTrusted: true,
        recentContactAdded: false,
        transactionVelocity: 1,
        isOnActiveCall: false,
      );

      final assessment = engine.calculate(signals);

      expect(assessment.score, 0);
      expect(assessment.level, RiskLevel.low);
      expect(assessment.isLowRisk, isTrue);
    });

    test('Medium Risk when amount exceeds 3x typical average (+3 pts)', () {
      final signals = RiskSignals(
        isNewRecipient: false,
        amount: 8000.0, // > 3 * 2500 = 7500
        avgTransactionAmount: 2500.0,
        timeOfDay: DateTime(2026, 9, 23, 15, 30),
        deviceTrusted: true,
        recentContactAdded: false,
        transactionVelocity: 1,
        isOnActiveCall: false,
      );

      final assessment = engine.calculate(signals);

      expect(assessment.score, 3);
      expect(assessment.level, RiskLevel.medium);
      expect(assessment.isMediumRisk, isTrue);
      expect(assessment.factors.any((f) => f.contains('higher than your typical average')), isTrue);
    });

    test('Medium Risk for new recipient with late night hours (2 + 1 = 3 pts)', () {
      final signals = RiskSignals(
        isNewRecipient: true, // +2
        amount: 1000.0,
        avgTransactionAmount: 2500.0,
        timeOfDay: DateTime(2026, 9, 23, 23, 45), // 11:45 PM -> +1
        deviceTrusted: true,
        recentContactAdded: false,
        transactionVelocity: 1,
        isOnActiveCall: false,
      );

      final assessment = engine.calculate(signals);

      expect(assessment.score, 3);
      expect(assessment.level, RiskLevel.medium);
    });

    test('High Risk for active call + new recipient + high amount (2 + 2 + 3 = 7 pts)', () {
      final signals = RiskSignals(
        isNewRecipient: true, // +2
        amount: 15000.0, // > 3 * 2500 -> +3
        avgTransactionAmount: 2500.0,
        timeOfDay: DateTime(2026, 9, 23, 11, 0),
        deviceTrusted: true,
        recentContactAdded: true, // +1
        transactionVelocity: 4, // > 3 -> +2
        isOnActiveCall: true, // +2
      );

      final assessment = engine.calculate(signals);

      // Score = 2 + 3 + 1 + 2 + 2 = 10
      expect(assessment.score, greaterThanOrEqualTo(6));
      expect(assessment.level, RiskLevel.high);
      expect(assessment.isHighRisk, isTrue);
      expect(assessment.factors.any((f) => f.contains('Active phone call')), isTrue);
    });

    test('Threshold boundary check: Score 2 is Low, Score 3 is Medium, Score 6 is High', () {
      // Score 2: New recipient (+2)
      final score2Signals = RiskSignals(
        isNewRecipient: true,
        amount: 500.0,
        avgTransactionAmount: 2500.0,
        timeOfDay: DateTime(2026, 9, 23, 12, 0),
      );
      expect(engine.calculate(score2Signals).level, RiskLevel.low);

      // Score 3: Amount > 3x (+3)
      final score3Signals = RiskSignals(
        isNewRecipient: false,
        amount: 8000.0,
        avgTransactionAmount: 2500.0,
        timeOfDay: DateTime(2026, 9, 23, 12, 0),
      );
      expect(engine.calculate(score3Signals).level, RiskLevel.medium);

      // Score 6: Amount > 3x (+3) + Active Call (+2) + Late Night (+1) = 6
      final score6Signals = RiskSignals(
        isNewRecipient: false,
        amount: 8000.0,
        avgTransactionAmount: 2500.0,
        timeOfDay: DateTime(2026, 9, 23, 1, 30), // late night (+1)
        isOnActiveCall: true, // (+2)
      );
      expect(engine.calculate(score6Signals).score, 6);
      expect(engine.calculate(score6Signals).level, RiskLevel.high);
    });
  });
}
