import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../providers/wallet_state.dart';
import 'home_dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletProvider);

    // Initial session checking state
    if (!state.isSessionInitialized) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isAuthenticated) {
      return const HomeDashboardScreen();
    }

    return const LoginScreen();
  }
}
