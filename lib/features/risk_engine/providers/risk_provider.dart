import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/risk_assessment.dart';
import '../models/risk_signals.dart';
import '../services/risk_engine.dart';

final riskEngineProvider = Provider<IRiskEngine>((ref) {
  return const RiskEngine();
});

class RiskSignalsNotifier extends Notifier<RiskSignals> {
  @override
  RiskSignals build() {
    return RiskSignals(timeOfDay: DateTime.now());
  }

  void updateSignals({
    bool? isNewRecipient,
    double? amount,
    double? avgTransactionAmount,
    DateTime? timeOfDay,
    bool? deviceTrusted,
    bool? recentContactAdded,
    int? transactionVelocity,
    bool? isOnActiveCall,
  }) {
    state = state.copyWith(
      isNewRecipient: isNewRecipient,
      amount: amount,
      avgTransactionAmount: avgTransactionAmount,
      timeOfDay: timeOfDay,
      deviceTrusted: deviceTrusted,
      recentContactAdded: recentContactAdded,
      transactionVelocity: transactionVelocity,
      isOnActiveCall: isOnActiveCall,
    );
  }

  void toggleActiveCall() {
    state = state.copyWith(isOnActiveCall: !state.isOnActiveCall);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void reset() {
    state = RiskSignals(timeOfDay: DateTime.now());
  }

  /// Preset for testing High Risk: New recipient + amount > 3x + active call
  void applyHighRiskPreset() {
    state = RiskSignals(
      isNewRecipient: true,
      amount: 15000.0,
      avgTransactionAmount: 2500.0,
      timeOfDay: DateTime.now(),
      isOnActiveCall: true,
      transactionVelocity: 4,
      recentContactAdded: true,
    );
  }

  /// Preset for testing Medium Risk: Amount > 3x average, trusted recipient
  void applyMediumRiskPreset() {
    state = RiskSignals(
      isNewRecipient: false,
      amount: 9500.0,
      avgTransactionAmount: 2500.0,
      timeOfDay: DateTime.now(),
      isOnActiveCall: false,
      transactionVelocity: 1,
    );
  }

  /// Preset for testing Low Risk: Usual amount, familiar contact
  void applyLowRiskPreset() {
    state = RiskSignals(
      isNewRecipient: false,
      amount: 450.0,
      avgTransactionAmount: 2500.0,
      timeOfDay: DateTime.now(),
      isOnActiveCall: false,
      transactionVelocity: 1,
    );
  }
}

final riskSignalsProvider =
    NotifierProvider<RiskSignalsNotifier, RiskSignals>(RiskSignalsNotifier.new);

final riskAssessmentProvider = Provider<RiskAssessment>((ref) {
  final engine = ref.watch(riskEngineProvider);
  final signals = ref.watch(riskSignalsProvider);
  return engine.calculate(signals);
});
