import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecurityState {
  final int overallScore; // out of 100
  final bool isCallGuardActive;
  final bool isSimSwapProtectionActive;
  final bool isVelocityLimiterActive;
  final bool isBiometricLockActive;
  final bool isAiCoercionDetectorActive;
  final int totalThreatsNeutralized;
  final DateTime lastAuditTime;

  const SecurityState({
    this.overallScore = 96,
    this.isCallGuardActive = true,
    this.isSimSwapProtectionActive = true,
    this.isVelocityLimiterActive = true,
    this.isBiometricLockActive = true,
    this.isAiCoercionDetectorActive = true,
    this.totalThreatsNeutralized = 14,
    required this.lastAuditTime,
  });

  SecurityState copyWith({
    int? overallScore,
    bool? isCallGuardActive,
    bool? isSimSwapProtectionActive,
    bool? isVelocityLimiterActive,
    bool? isBiometricLockActive,
    bool? isAiCoercionDetectorActive,
    int? totalThreatsNeutralized,
    DateTime? lastAuditTime,
  }) {
    return SecurityState(
      overallScore: overallScore ?? this.overallScore,
      isCallGuardActive: isCallGuardActive ?? this.isCallGuardActive,
      isSimSwapProtectionActive:
          isSimSwapProtectionActive ?? this.isSimSwapProtectionActive,
      isVelocityLimiterActive:
          isVelocityLimiterActive ?? this.isVelocityLimiterActive,
      isBiometricLockActive:
          isBiometricLockActive ?? this.isBiometricLockActive,
      isAiCoercionDetectorActive:
          isAiCoercionDetectorActive ?? this.isAiCoercionDetectorActive,
      totalThreatsNeutralized:
          totalThreatsNeutralized ?? this.totalThreatsNeutralized,
      lastAuditTime: lastAuditTime ?? this.lastAuditTime,
    );
  }
}

class SecurityNotifier extends Notifier<SecurityState> {
  @override
  SecurityState build() {
    return SecurityState(lastAuditTime: DateTime.now());
  }

  void toggleCallGuard() {
    state = state.copyWith(isCallGuardActive: !state.isCallGuardActive);
    _recalcScore();
  }

  void toggleSimSwap() {
    state = state.copyWith(
        isSimSwapProtectionActive: !state.isSimSwapProtectionActive);
    _recalcScore();
  }

  void toggleVelocity() {
    state = state.copyWith(
        isVelocityLimiterActive: !state.isVelocityLimiterActive);
    _recalcScore();
  }

  void toggleBiometrics() {
    state = state.copyWith(
        isBiometricLockActive: !state.isBiometricLockActive);
    _recalcScore();
  }

  void toggleAiCoercion() {
    state = state.copyWith(
        isAiCoercionDetectorActive: !state.isAiCoercionDetectorActive);
    _recalcScore();
  }

  void _recalcScore() {
    int score = 50;
    if (state.isCallGuardActive) score += 10;
    if (state.isSimSwapProtectionActive) score += 10;
    if (state.isVelocityLimiterActive) score += 10;
    if (state.isBiometricLockActive) score += 10;
    if (state.isAiCoercionDetectorActive) score += 10;
    state = state.copyWith(overallScore: score, lastAuditTime: DateTime.now());
  }
}

final securityProvider =
    NotifierProvider<SecurityNotifier, SecurityState>(SecurityNotifier.new);
