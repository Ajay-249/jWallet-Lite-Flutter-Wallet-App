import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: JWalletApp(),
    ),
  );
}

class JWalletApp extends StatelessWidget {
  const JWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'jWallet Lite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
