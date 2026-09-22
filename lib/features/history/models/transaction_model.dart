import '../../risk_engine/models/risk_level.dart';

enum TransactionStatus {
  completed,
  flagged,
  blocked,
  pending;

  String get displayName {
    switch (this) {
      case TransactionStatus.completed:
        return 'Success';
      case TransactionStatus.flagged:
        return 'Flagged';
      case TransactionStatus.blocked:
        return 'Blocked';
      case TransactionStatus.pending:
        return 'Pending';
    }
  }
}

class TransactionModel {
  final String id;
  final String recipientName;
  final String recipientUpiId;
  final double amount;
  final DateTime timestamp;
  final TransactionStatus status;
  final RiskLevel riskLevel;
  final String? note;
  final List<String> riskReasons;
  final String? bankReference;

  const TransactionModel({
    required this.id,
    required this.recipientName,
    required this.recipientUpiId,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.riskLevel,
    this.note,
    this.riskReasons = const [],
    this.bankReference,
  });
}
