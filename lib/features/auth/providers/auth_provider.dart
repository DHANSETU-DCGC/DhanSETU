import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_auth_service.dart';

final localAuthServiceProvider = Provider<LocalAuthService>((ref) {
  return LocalAuthService();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String userName;
  final String userUpiId;
  final String userPhone;
  final double currentBalance;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.userName = 'Aarav Sharma',
    this.userUpiId = 'aarav@oksecure',
    this.userPhone = '+91 98765 43210',
    this.currentBalance = 48520.50,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? userName,
    String? userUpiId,
    String? userPhone,
    double? currentBalance,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userName: userName ?? this.userName,
      userUpiId: userUpiId ?? this.userUpiId,
      userPhone: userPhone ?? this.userPhone,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<bool> authenticateWithBiometrics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final authService = ref.read(localAuthServiceProvider);
      final success = await authService.authenticate(
        reason: 'Scan fingerprint or Face ID to unlock SecurePay',
      );
      if (success) {
        state = state.copyWith(isAuthenticated: true, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Authentication cancelled or failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Biometric error: $e',
      );
      return false;
    }
  }

  bool verifyPin(String enteredPin) {
    if (enteredPin == '1234' || enteredPin.length == 4) {
      state = state.copyWith(isAuthenticated: true, errorMessage: null);
      return true;
    } else {
      state = state.copyWith(errorMessage: 'Invalid Security PIN');
      return false;
    }
  }

  void logout() {
    state = state.copyWith(isAuthenticated: false);
  }

  void deductBalance(double amount) {
    final newBalance =
        (state.currentBalance - amount).clamp(0.0, double.infinity);
    state = state.copyWith(currentBalance: newBalance);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
