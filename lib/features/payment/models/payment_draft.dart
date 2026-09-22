import '../../risk_engine/models/risk_assessment.dart';
import '../../risk_engine/models/risk_signals.dart';
import 'recipient.dart';

class PaymentDraft {
  final String draftId;
  final Recipient recipient;
  final double amount;
  final String note;
  final RiskSignals riskSignals;
  final RiskAssessment? riskAssessment;
  final bool? pressured;
  final String selectedBank;
  final String? transactionReference;

  const PaymentDraft({
    required this.draftId,
    required this.recipient,
    required this.amount,
    this.note = '',
    required this.riskSignals,
    this.riskAssessment,
    this.pressured,
    this.selectedBank = 'HDFC Bank - •••• 4821',
    this.transactionReference,
  });

  PaymentDraft copyWith({
    String? draftId,
    Recipient? recipient,
    double? amount,
    String? note,
    RiskSignals? riskSignals,
    RiskAssessment? riskAssessment,
    bool? pressured,
    String? selectedBank,
    String? transactionReference,
  }) {
    return PaymentDraft(
      draftId: draftId ?? this.draftId,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      riskSignals: riskSignals ?? this.riskSignals,
      riskAssessment: riskAssessment ?? this.riskAssessment,
      pressured: pressured ?? this.pressured,
      selectedBank: selectedBank ?? this.selectedBank,
      transactionReference: transactionReference ?? this.transactionReference,
    );
  }
}
