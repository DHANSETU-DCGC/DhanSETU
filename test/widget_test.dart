import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_pay/main.dart';

void main() {
  testWidgets('SecurePayApp smoke test and splash to login navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SecurePayApp(),
      ),
    );

    // Initial frame on splash screen
    expect(find.text('SecurePay'), findsOneWidget);
    expect(find.text('Real-Time Protected UPI Payments'), findsOneWidget);

    // Fast-forward the 2-second splash timer
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    // Verifies navigation reached the Login screen
    expect(find.text('Welcome back, Aarav Sharma'), findsOneWidget);
    expect(find.text('Biometrics'), findsOneWidget);
    expect(find.text('App PIN'), findsOneWidget);
  });
}
