import '../../risk_engine/models/risk_level.dart';
import '../models/transaction_model.dart';

abstract class IHistoryRepository {
  List<TransactionModel> getInitialTransactions();
  Future<List<TransactionModel>> getTransactions();
  Future<void> addTransaction(TransactionModel transaction);
}

class MockHistoryRepository implements IHistoryRepository {
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: 'tx_101',
      recipientName: 'Priya Sharma',
      recipientUpiId: 'priya.sharma@okhdfcbank',
      amount: 450.00,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      status: TransactionStatus.completed,
      riskLevel: RiskLevel.low,
      note: 'Lunch share',
      riskReasons: ['Known recipient and normal velocity profile'],
      bankReference: 'UPI/23910394/91823',
    ),
    TransactionModel(
      id: 'tx_102',
      recipientName: 'Kavita Departmental Store',
      recipientUpiId: 'kavitastore@axl',
      amount: 1280.00,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: TransactionStatus.completed,
      riskLevel: RiskLevel.low,
      note: 'Weekly groceries',
      riskReasons: ['Known verified merchant'],
      bankReference: 'UPI/48201948/10492',
    ),
    TransactionModel(
      id: 'tx_103',
      recipientName: 'Rohan Mehta',
      recipientUpiId: 'rohan.mehta@oksbi',
      amount: 8500.00,
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      status: TransactionStatus.completed,
      riskLevel: RiskLevel.medium,
      note: 'Quarterly internet & electricity bill split',
      riskReasons: ['Amount higher than 3x user typical average'],
      bankReference: 'UPI/59201948/84729',
    ),
    TransactionModel(
      id: 'tx_104',
      recipientName: 'Telecom KYC Support - Rajat',
      recipientUpiId: 'kyc.verification.bill@paytm',
      amount: 14999.00,
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
      status: TransactionStatus.blocked,
      riskLevel: RiskLevel.high,
      note: 'Prevented scam transfer',
      riskReasons: [
        'Active call detected during payment attempt',
        'New unverified recipient with 8 scam flags',
        'User confirmed pressure tactics in questionnaire',
      ],
      bankReference: 'BLOCKED/FRAUD_SENTINEL/9941',
    ),
    TransactionModel(
      id: 'tx_105',
      recipientName: 'Sneha Patel',
      recipientUpiId: 'sneha.patel@icici',
      amount: 600.00,
      timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 8)),
      status: TransactionStatus.completed,
      riskLevel: RiskLevel.low,
      note: 'Movie tickets',
      riskReasons: ['Verified contact'],
      bankReference: 'UPI/19204829/49102',
    ),
  ];

  @override
  List<TransactionModel> getInitialTransactions() {
    return List.unmodifiable(_transactions);
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_transactions);
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.insert(0, transaction);
  }
}
