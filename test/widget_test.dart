import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jwallet_lite/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('jWallet Lite smoke test - renders Login Screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: JWalletApp(),
      ),
    );

    // Pump frames to complete microtasks
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Verify that the title and login widgets render
    expect(find.text('jWallet'), findsOneWidget);
    expect(find.text('LITE'), findsOneWidget);
    expect(find.text('Sign In to Wallet'), findsOneWidget);
  });
}
