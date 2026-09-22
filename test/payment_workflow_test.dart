import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_pay/features/auth/providers/auth_provider.dart';
import 'package:secure_pay/features/history/models/transaction_model.dart';
import 'package:secure_pay/features/history/providers/history_provider.dart';
import 'package:secure_pay/features/payment/models/recipient.dart';
import 'package:secure_pay/features/payment/providers/payment_provider.dart';
import 'package:secure_pay/features/risk_engine/models/risk_level.dart';
import 'package:secure_pay/features/risk_engine/providers/risk_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('SecurePay End-to-End Payment Workflow Tests', () {
    const trustedRecipient = Recipient(
      id: 'rec_test_1',
      name: 'Priya Sharma',
      upiId: 'priya@okhdfcbank',
      phone: '+91 98201 11223',
      isVerified: true,
      accountAgeDays: 1200,
      trustScore: 98,
      fraudReportsCount: 0,
      isNewRecipient: false,
    );

    const suspiciousRecipient = Recipient(
      id: 'rec_test_2',
      name: 'Cyber Threat Unknown',
      upiId: 'scammer@ybl',
      phone: '+91 88990 01122',
      isVerified: false,
      accountAgeDays: 3,
      trustScore: 12,
      fraudReportsCount: 15,
      isNewRecipient: true,
    );

    test('Workflow 1: Low risk path evaluation', () {
      final paymentNotifier = container.read(paymentProvider.notifier);

      paymentNotifier.initDraft(trustedRecipient, amount: 450.0);
      container.read(riskSignalsProvider.notifier).applyLowRiskPreset();

      final riskLevel = paymentNotifier.evaluateCurrentRisk();

      expect(riskLevel, RiskLevel.low);
      final draft = container.read(paymentProvider).draft;
      expect(draft?.riskAssessment?.level, RiskLevel.low);
      expect(draft?.riskAssessment?.score, lessThanOrEqualTo(2));
    });

    test('Workflow 2: Medium risk path evaluation (Unusual amount)', () {
      final paymentNotifier = container.read(paymentProvider.notifier);

      paymentNotifier.initDraft(trustedRecipient, amount: 9500.0);
      container.read(riskSignalsProvider.notifier).applyMediumRiskPreset();

      final riskLevel = paymentNotifier.evaluateCurrentRisk();

      expect(riskLevel, RiskLevel.medium);
      final draft = container.read(paymentProvider).draft;
      expect(draft?.riskAssessment?.score, inInclusiveRange(3, 5));
    });

    test('Workflow 3: High risk path evaluation (Active Call + New Flagged Recipient)', () {
      final paymentNotifier = container.read(paymentProvider.notifier);

      paymentNotifier.initDraft(suspiciousRecipient, amount: 15000.0);
      container.read(riskSignalsProvider.notifier).applyHighRiskPreset();

      final riskLevel = paymentNotifier.evaluateCurrentRisk();

      expect(riskLevel, RiskLevel.high);
      final draft = container.read(paymentProvider).draft;
      expect(draft?.riskAssessment?.score, greaterThanOrEqualTo(6));
      expect(draft?.riskAssessment?.isHighRisk, isTrue);

      // Pressure check YES branch
      paymentNotifier.setPressureCheckResponse(true);
      expect(container.read(paymentProvider).draft?.pressured, isTrue);

      // Pressure check NO branch
      paymentNotifier.setPressureCheckResponse(false);
      expect(container.read(paymentProvider).draft?.pressured, isFalse);
    });

    test('Workflow 4: Payment execution deducts balance and appends to history', () async {
      final initialBalance = container.read(authProvider).currentBalance;
      final initialTxCount = container.read(historyProvider).transactions.length;

      final paymentNotifier = container.read(paymentProvider.notifier);
      paymentNotifier.initDraft(trustedRecipient, amount: 1000.0);
      paymentNotifier.evaluateCurrentRisk();

      final success = await paymentNotifier.executePayment();

      expect(success, isTrue);
      expect(container.read(authProvider).currentBalance, initialBalance - 1000.0);
      expect(container.read(historyProvider).transactions.length, initialTxCount + 1);

      final latestTx = container.read(historyProvider).transactions.first;
      expect(latestTx.amount, 1000.0);
      expect(latestTx.recipientName, trustedRecipient.name);
      expect(latestTx.status, TransactionStatus.completed);
    });

    test('Workflow 5: High risk cancellation logs blocked transaction', () {
      final initialTxCount = container.read(historyProvider).transactions.length;

      final paymentNotifier = container.read(paymentProvider.notifier);
      paymentNotifier.initDraft(suspiciousRecipient, amount: 15000.0);
      container.read(riskSignalsProvider.notifier).applyHighRiskPreset();
      paymentNotifier.evaluateCurrentRisk();

      paymentNotifier.cancelCurrentPayment('Emergency cancel by user at Fraud Alert');

      expect(container.read(paymentProvider).draft, isNull);
      expect(container.read(historyProvider).transactions.length, initialTxCount + 1);

      final blockedTx = container.read(historyProvider).transactions.first;
      expect(blockedTx.status, TransactionStatus.blocked);
      expect(blockedTx.riskLevel, RiskLevel.high);
    });
  });
}
