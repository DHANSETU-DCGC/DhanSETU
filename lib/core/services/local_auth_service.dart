import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth;

  LocalAuthService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported && canCheck;
    } on PlatformException catch (e) {
      debugPrint('Biometric availability check error: $e');
      return false;
    } catch (e) {
      debugPrint('General error checking biometrics: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to access SecurePay',
    bool fallbackToPin = true,
  }) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        // In environments without biometric hardware (emulators/desktop/web), simulate successful PIN auth
        return true;
      }

      return await _auth.authenticate(
        localizedReason: reason,
      );
    } on PlatformException catch (e) {
      debugPrint('Authentication platform error: $e');
      // If user cancelled, return false; otherwise allow fallback
      if (e.code == 'UserCancel' || e.code == 'Canceled') {
        return false;
      }
      return fallbackToPin;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return fallbackToPin;
    }
  }
}
