import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/wallet_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/status_badge.dart';
import 'home_dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'demo@jstack.co');
  final _passwordController = TextEditingController(text: 'Demo@123');
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _autofillDemo() {
    setState(() {
      _emailController.text = 'demo@jstack.co';
      _passwordController.text = 'Demo@123';
      _emailError = null;
      _passwordError = null;
    });
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;
    if (email.isEmpty) {
      setState(() => _emailError = 'Email address is required');
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email address');
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    }

    if (!isValid) return;

    final success = await ref
        .read(walletProvider.notifier)
        .login(email, password);

    if (!mounted) return;

    final state = ref.read(walletProvider);
    if (!success || state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Login failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Logo Badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineLight),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onSurface.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC2652A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // App Title & Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'jWallet',
                    style: AppTextStyles.headlineSerif(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'LITE',
                      style: AppTextStyles.label(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Secure digital wallet & instant transfers',
                style: AppTextStyles.bodySans(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Quick Demo Access Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.key_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'QUICK DEMO ACCESS',
                              style: AppTextStyles.label(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _autofillDemo,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Auto-fill',
                                  style: AppTextStyles.label(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Email:',
                                style: AppTextStyles.bodySans(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                'demo@jstack.co',
                                style: AppTextStyles.bodySans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Password:',
                                style: AppTextStyles.bodySans(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                'Demo@123',
                                style: AppTextStyles.bodySans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Inputs Section
              CustomTextField(
                label: 'Account Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hint: 'name@jstack.co',
                errorText: _emailError,
                prefixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                trailingBadge: StatusBadge(
                  label: 'VALID',
                  backgroundColor: AppColors.surfaceContainer,
                  textColor: AppColors.primary,
                  borderColor: AppColors.outlineLight,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Security Pin / Password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                hint: '••••••••',
                errorText: _passwordError,
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                trailingBadge: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Use demo credentials: Demo@123'),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot?',
                    style: AppTextStyles.label(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Trust Device Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Login Button
              CustomButton(
                text: 'Sign In to Wallet',
                suffixIcon: Icons.arrow_forward_rounded,
                isLoading: state.isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC2652A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Mock API Server Connected • v1.0.4-lite',
                    style: AppTextStyles.bodySans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
