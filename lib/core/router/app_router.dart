import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/history/presentation/transaction_history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/payment/presentation/fraud_alert_screen.dart';
import '../../features/payment/presentation/payment_confirmation_low_screen.dart';
import '../../features/payment/presentation/payment_confirmation_medium_screen.dart';
import '../../features/payment/presentation/payment_interception_screen.dart';
import '../../features/payment/presentation/payment_success_screen.dart';
import '../../features/payment/presentation/pressure_check_screen.dart';
import '../../features/payment/presentation/recipient_profiling_screen.dart';
import '../../features/payment/presentation/send_money_screen.dart';
import '../../features/payment/presentation/verification_steps_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/security_center/presentation/security_center_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggingIn =
          state.matchedLocation == '/login' || state.matchedLocation == '/splash';

      if (!authState.isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (authState.isAuthenticated && state.matchedLocation == '/login') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/send-money',
        name: 'send-money',
        builder: (context, state) => const SendMoneyScreen(),
      ),
      GoRoute(
        path: '/recipient-profile',
        name: 'recipient-profile',
        builder: (context, state) => const RecipientProfilingScreen(),
      ),
      GoRoute(
        path: '/confirm-low',
        name: 'confirm-low',
        builder: (context, state) => const PaymentConfirmationLowScreen(),
      ),
      GoRoute(
        path: '/confirm-medium',
        name: 'confirm-medium',
        builder: (context, state) => const PaymentConfirmationMediumScreen(),
      ),
      GoRoute(
        path: '/fraud-alert',
        name: 'fraud-alert',
        builder: (context, state) => const FraudAlertScreen(),
      ),
      GoRoute(
        path: '/pressure-check',
        name: 'pressure-check',
        builder: (context, state) => const PressureCheckScreen(),
      ),
      GoRoute(
        path: '/verification-steps',
        name: 'verification-steps',
        builder: (context, state) => const VerificationStepsScreen(),
      ),
      GoRoute(
        path: '/payment-interception',
        name: 'payment-interception',
        builder: (context, state) => const PaymentInterceptionScreen(),
      ),
      GoRoute(
        path: '/security-center',
        name: 'security-center',
        builder: (context, state) => const SecurityCenterScreen(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/payment-success',
        name: 'payment-success',
        builder: (context, state) => const PaymentSuccessScreen(),
      ),
    ],
  );
});
