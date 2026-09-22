import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isUsingPin = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onBiometricPressed() async {
    final success =
        await ref.read(authProvider.notifier).authenticateWithBiometrics();
    if (success && mounted) {
      context.go('/home');
    }
  }

  void _onPinDigit(String digit) {
    if (_pinController.text.length < 4) {
      setState(() {
        _pinController.text += digit;
      });

      if (_pinController.text.length == 4) {
        final ok = ref.read(authProvider.notifier).verifyPin(_pinController.text);
        if (ok) {
          context.go('/home');
        } else {
          _pinController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect PIN. Try 1234 or use Biometrics.'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _onPinBackspace() {
    if (_pinController.text.isNotEmpty) {
      setState(() {
        _pinController.text = _pinController.text.substring(
          0,
          _pinController.text.length - 1,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // App Brand Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SecurePay',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // User Info
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  'AS',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome back, ${authState.userName}',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                authState.userUpiId,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Mode toggle (Biometric vs PIN)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isUsingPin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isUsingPin
                                ? AppColors.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: !_isUsingPin
                                ? [
                                    const BoxShadow(
                                      color: Color(0x0A000000),
                                      blurRadius: 4,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fingerprint_rounded,
                                size: 16,
                                color: !_isUsingPin
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Biometrics',
                                style: AppTypography.labelSmall.copyWith(
                                  color: !_isUsingPin
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isUsingPin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isUsingPin
                                ? AppColors.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _isUsingPin
                                ? [
                                    const BoxShadow(
                                      color: Color(0x0A000000),
                                      blurRadius: 4,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.dialpad_rounded,
                                size: 16,
                                color: _isUsingPin
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'App PIN',
                                style: AppTypography.labelSmall.copyWith(
                                  color: _isUsingPin
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (!_isUsingPin) ...[
                // Biometric Graphic / Trigger
                GestureDetector(
                  onTap: _onBiometricPressed,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.primaryLight, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      size: 52,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Tap to scan Fingerprint or Face ID',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  text: 'Unlock with Biometrics',
                  icon: Icons.fingerprint_rounded,
                  isLoading: authState.isLoading,
                  onPressed: _onBiometricPressed,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Demo Instant Bypass
                    ref.read(authProvider.notifier).verifyPin('1234');
                    context.go('/home');
                  },
                  child: const Text('Quick Demo Bypass (Skip Auth)'),
                ),
              ] else ...[
                // PIN input dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final filled = index < _pinController.text.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? AppColors.primary : AppColors.surface,
                        border: Border.all(
                          color: filled ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // PIN Keypad grid
                _buildPinKeypad(),
              ],

              const SizedBox(height: 24),

              // Security footer note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.security_rounded,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Protected by On-Device Risk Sentinel',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinKeypad() {
    return Column(
      children: [
        for (var r = 0; r < 3; r++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var c = 1; c <= 3; c++)
                _buildPinKey('${r * 3 + c}'),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 64, height: 54),
            _buildPinKey('0'),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _onPinBackspace,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 64,
                  height: 54,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinKey(String num) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onPinDigit(num),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 64,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            num,
            style: AppTypography.headlineSmall.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
