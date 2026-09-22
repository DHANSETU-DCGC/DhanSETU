import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/models/transaction_model.dart';
import '../../history/providers/history_provider.dart';
import '../../risk_engine/models/risk_level.dart';
import '../../risk_engine/providers/risk_provider.dart';
import '../data/mock_payment_repository.dart';
import '../models/payment_draft.dart';
import '../models/recipient.dart';

final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) {
  return MockPaymentRepository();
});

final recipientListProvider =
    FutureProvider.family<List<Recipient>, String>((ref, query) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getRecipients(query: query);
});

class PaymentState {
  final PaymentDraft? draft;
  final bool isProcessing;
  final String? errorMessage;
  final TransactionModel? completedTransaction;

  const PaymentState({
    this.draft,
    this.isProcessing = false,
    this.errorMessage,
    this.completedTransaction,
  });

  PaymentState copyWith({
    PaymentDraft? draft,
    bool? isProcessing,
    String? errorMessage,
    TransactionModel? completedTransaction,
    bool clearDraft = false,
  }) {
    return PaymentState(
      draft: clearDraft ? null : (draft ?? this.draft),
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      completedTransaction: completedTransaction ?? this.completedTransaction,
    );
  }
}

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() {
    return const PaymentState();
  }

  void initDraft(Recipient recipient, {double amount = 0.0}) {
    final activeSignals = ref.read(riskSignalsProvider);
    final updatedSignals = activeSignals.copyWith(
      isNewRecipient: recipient.isNewRecipient,
      amount: amount,
      recentContactAdded: recipient.accountAgeDays < 7,
    );

    ref.read(riskSignalsProvider.notifier).updateSignals(
          isNewRecipient: recipient.isNewRecipient,
          amount: amount,
          recentContactAdded: recipient.accountAgeDays < 7,
        );

    final draft = PaymentDraft(
      draftId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      recipient: recipient,
      amount: amount,
      riskSignals: updatedSignals,
    );

    state = state.copyWith(draft: draft, errorMessage: null);
  }

  void updateAmount(double amount) {
    if (state.draft == null) return;
    final updatedSignals = state.draft!.riskSignals.copyWith(amount: amount);
    ref.read(riskSignalsProvider.notifier).setAmount(amount);

    final updatedDraft = state.draft!.copyWith(
      amount: amount,
      riskSignals: updatedSignals,
    );

    state = state.copyWith(draft: updatedDraft);
  }

  void updateNote(String note) {
    if (state.draft == null) return;
    state = state.copyWith(draft: state.draft!.copyWith(note: note));
  }

  RiskLevel evaluateCurrentRisk() {
    if (state.draft == null) return RiskLevel.low;

    final engine = ref.read(riskEngineProvider);
    final activeSignals = ref.read(riskSignalsProvider);

    final finalSignals = activeSignals.copyWith(
      isNewRecipient: state.draft!.recipient.isNewRecipient,
      amount: state.draft!.amount,
    );

    final assessment = engine.calculate(finalSignals);

    final updatedDraft = state.draft!.copyWith(
      riskSignals: finalSignals,
      riskAssessment: assessment,
    );

    state = state.copyWith(draft: updatedDraft);
    return assessment.level;
  }

  void setPressureCheckResponse(bool pressured) {
    if (state.draft == null) return;
    state = state.copyWith(
      draft: state.draft!.copyWith(pressured: pressured),
    );
  }

  Future<bool> executePayment() async {
    if (state.draft == null) return false;

    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      final repo = ref.read(paymentRepositoryProvider);
      final success = await repo.processPayment(state.draft!);

      if (success) {
        final randomRef =
            'UPI/${Random().nextInt(89999999) + 10000000}/${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

        final completedTx = TransactionModel(
          id: state.draft!.draftId,
          recipientName: state.draft!.recipient.name,
          recipientUpiId: state.draft!.recipient.upiId,
          amount: state.draft!.amount,
          timestamp: DateTime.now(),
          status: TransactionStatus.completed,
          riskLevel: state.draft!.riskAssessment?.level ?? RiskLevel.low,
          note: state.draft!.note,
          riskReasons: state.draft!.riskAssessment?.factors ?? [],
          bankReference: randomRef,
        );

        ref.read(authProvider.notifier).deductBalance(state.draft!.amount);
        await ref.read(historyProvider.notifier).addTransaction(completedTx);

        state = state.copyWith(
          isProcessing: false,
          completedTransaction: completedTx,
        );
        return true;
      } else {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'Payment gateway rejected the transaction.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Payment error: $e',
      );
      return false;
    }
  }

  void cancelCurrentPayment(String reason) {
    if (state.draft != null) {
      if (state.draft!.riskAssessment?.level == RiskLevel.high) {
        final blockedTx = TransactionModel(
          id: state.draft!.draftId,
          recipientName: state.draft!.recipient.name,
          recipientUpiId: state.draft!.recipient.upiId,
          amount: state.draft!.amount,
          timestamp: DateTime.now(),
          status: TransactionStatus.blocked,
          riskLevel: RiskLevel.high,
          note: 'Payment halted by user: $reason',
          riskReasons: state.draft!.riskAssessment?.factors ?? [],
        );
        ref.read(historyProvider.notifier).addTransaction(blockedTx);
      }
    }
    state = state.copyWith(clearDraft: true);
  }

  void reset() {
    state = const PaymentState();
  }
}

final paymentProvider =
    NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);
