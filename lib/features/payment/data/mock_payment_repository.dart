import '../models/payment_draft.dart';
import '../models/recipient.dart';

abstract class IPaymentRepository {
  Future<List<Recipient>> getRecipients({String? query});
  Future<Recipient?> getRecipientById(String id);
  Future<bool> processPayment(PaymentDraft draft);
  Future<bool> cancelPayment(String draftId, String reason);
}

class MockPaymentRepository implements IPaymentRepository {
  final List<Recipient> _mockRecipients = [
    const Recipient(
      id: 'rec_01',
      name: 'Priya Sharma',
      upiId: 'priya.sharma@okhdfcbank',
      phone: '+91 98201 11223',
      isVerified: true,
      accountAgeDays: 1450,
      trustScore: 99,
      fraudReportsCount: 0,
      isNewRecipient: false,
      category: 'Family & Friends',
      bankName: 'HDFC Bank',
    ),
    const Recipient(
      id: 'rec_02',
      name: 'Rohan Mehta',
      upiId: 'rohan.mehta@oksbi',
      phone: '+91 97654 33211',
      isVerified: true,
      accountAgeDays: 680,
      trustScore: 94,
      fraudReportsCount: 0,
      isNewRecipient: false,
      category: 'Work & Colleagues',
      bankName: 'State Bank of India',
    ),
    const Recipient(
      id: 'rec_03',
      name: 'Sneha Patel',
      upiId: 'sneha.patel@icici',
      phone: '+91 91234 56789',
      isVerified: true,
      accountAgeDays: 410,
      trustScore: 91,
      fraudReportsCount: 0,
      isNewRecipient: false,
      category: 'Personal',
      bankName: 'ICICI Bank',
    ),
    const Recipient(
      id: 'rec_04',
      name: 'QuickLoan Support (Unverified)',
      upiId: 'loan.processing99@ybl',
      phone: '+91 88990 01122',
      isVerified: false,
      accountAgeDays: 4,
      trustScore: 16,
      fraudReportsCount: 14,
      isNewRecipient: true,
      category: 'Unknown / Flagged',
      bankName: 'Yes Bank',
    ),
    const Recipient(
      id: 'rec_05',
      name: 'Telecom KYC Support - Rajat',
      upiId: 'kyc.verification.bill@paytm',
      phone: '+91 77665 44332',
      isVerified: false,
      accountAgeDays: 9,
      trustScore: 22,
      fraudReportsCount: 8,
      isNewRecipient: true,
      category: 'Suspected Coercion',
      bankName: 'Paytm Payments Bank',
    ),
    const Recipient(
      id: 'rec_06',
      name: 'Kavita Departmental Store',
      upiId: 'kavitastore@axl',
      phone: '+91 99887 76655',
      isVerified: true,
      accountAgeDays: 890,
      trustScore: 96,
      fraudReportsCount: 0,
      isNewRecipient: false,
      category: 'Merchant Grocery',
      bankName: 'Axis Bank',
    ),
  ];

  @override
  Future<List<Recipient>> getRecipients({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (query == null || query.trim().isEmpty) {
      return List.unmodifiable(_mockRecipients);
    }
    final q = query.toLowerCase();
    return _mockRecipients.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.upiId.toLowerCase().contains(q) ||
          r.phone.contains(q);
    }).toList();
  }

  @override
  Future<Recipient?> getRecipientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _mockRecipients.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> processPayment(PaymentDraft draft) async {
    // Simulate payment gateway settlement delay
    await Future.delayed(const Duration(milliseconds: 1200));
    return true;
  }

  @override
  Future<bool> cancelPayment(String draftId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
