class Recipient {
  final String id;
  final String name;
  final String upiId;
  final String phone;
  final bool isVerified;
  final int accountAgeDays;
  final int trustScore; // 0 to 100
  final int fraudReportsCount;
  final bool isNewRecipient;
  final String category;
  final String bankName;

  const Recipient({
    required this.id,
    required this.name,
    required this.upiId,
    required this.phone,
    this.isVerified = true,
    this.accountAgeDays = 365,
    this.trustScore = 95,
    this.fraudReportsCount = 0,
    this.isNewRecipient = false,
    this.category = 'Personal',
    this.bankName = 'HDFC Bank',
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String get formattedAccountAge {
    if (accountAgeDays > 365) {
      final years = (accountAgeDays / 365).toStringAsFixed(1);
      return '$years years active';
    } else if (accountAgeDays > 30) {
      final months = (accountAgeDays / 30).round();
      return '$months months active';
    } else {
      return '$accountAgeDays days active (New Account)';
    }
  }
}
