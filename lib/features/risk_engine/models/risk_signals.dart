class RiskSignals {
  final bool isNewRecipient;
  final double amount;
  final double avgTransactionAmount;
  final DateTime timeOfDay;
  final bool deviceTrusted;
  final bool recentContactAdded;
  final int transactionVelocity; // Number of transactions within the past hour
  final bool isOnActiveCall; // Demo toggle for call impersonation fraud

  const RiskSignals({
    this.isNewRecipient = false,
    this.amount = 0.0,
    this.avgTransactionAmount = 2500.0,
    required this.timeOfDay,
    this.deviceTrusted = true,
    this.recentContactAdded = false,
    this.transactionVelocity = 1,
    this.isOnActiveCall = false,
  });

  bool get isLateNight {
    final hour = timeOfDay.hour;
    // Late night defined as 11 PM (23) through 5 AM (05)
    return hour >= 23 || hour < 5;
  }

  bool get isAmountExceedingThreshold {
    return amount > (3 * avgTransactionAmount);
  }

  RiskSignals copyWith({
    bool? isNewRecipient,
    double? amount,
    double? avgTransactionAmount,
    DateTime? timeOfDay,
    bool? deviceTrusted,
    bool? recentContactAdded,
    int? transactionVelocity,
    bool? isOnActiveCall,
  }) {
    return RiskSignals(
      isNewRecipient: isNewRecipient ?? this.isNewRecipient,
      amount: amount ?? this.amount,
      avgTransactionAmount: avgTransactionAmount ?? this.avgTransactionAmount,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      deviceTrusted: deviceTrusted ?? this.deviceTrusted,
      recentContactAdded: recentContactAdded ?? this.recentContactAdded,
      transactionVelocity: transactionVelocity ?? this.transactionVelocity,
      isOnActiveCall: isOnActiveCall ?? this.isOnActiveCall,
    );
  }
}
