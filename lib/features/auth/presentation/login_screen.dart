import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/third_eye_icon.dart';
import '../domain/auth_state.dart' as app_auth;
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _otpMode = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final phone = '+91${_phoneCtrl.text.trim()}';
    if (_otpMode) {
      await ref.read(authStateProvider.notifier).sendOtp(phone: phone);
    } else {
      await ref.read(authStateProvider.notifier).signInWithPhone(
            phone: phone,
            password: _passwordCtrl.text,
          );
    }
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your registered email address to receive a password reset link.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty || !v.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  ref
                      .read(authStateProvider.notifier)
                      .sendPasswordReset(emailCtrl.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to your email.'),
                    ),
                  );
                }
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is app_auth.AuthLoading;
    final error = authState is app_auth.AuthError ? authState.message : null;

    return Scaffold(
      body: Stack(
        children: [
          _Background(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _LoginCard(
                  formKey: _formKey,
                  phoneCtrl: _phoneCtrl,
                  passwordCtrl: _passwordCtrl,
                  obscurePassword: _obscurePassword,
                  otpMode: _otpMode,
                  isLoading: isLoading,
                  error: error,
                  onTogglePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onToggleOtpMode: () =>
                      setState(() => _otpMode = !_otpMode),
                  onForgotPassword: _showForgotPasswordDialog,
                  onSubmit: _submit,
                ),
              ),
            ),
          ),
          if (isLoading)
            LoadingOverlay(
              message: _otpMode ? 'Sending OTP…' : 'Signing in…',
            ),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            Color(0xFF1E1740),
            AppColors.bgDark,
          ],
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.obscurePassword,
    required this.otpMode,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleOtpMode,
    required this.onForgotPassword,
    required this.onSubmit,
    this.error,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final bool otpMode;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleOtpMode;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentViolet.withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ThirdEyeIcon(size: 56, color: AppColors.accentViolet),
            const SizedBox(height: 16),
            Text('Divinity', style: tt.headlineMedium),
            Text(
              'THE THIRD EYE',
              style: tt.labelMedium?.copyWith(
                color: AppColors.accentViolet,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 32),
            if (error != null) ...[
              _ErrorBanner(message: error!),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+91 ',
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.length != 10) {
                  return 'Enter a valid 10-digit number';
                }
                return null;
              },
            ),
            if (!otpMode) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordCtrl,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: onTogglePassword,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter your password' : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onForgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.accentViolet,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: Text(otpMode ? 'Send OTP' : 'Sign In'),
              ),
            ),
            // OTP login option is disabled for the closed beta (relying on password login)
            /*
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading ? null : onToggleOtpMode,
              child: Text(
                otpMode
                    ? 'Sign in with password instead'
                    : 'Sign in with OTP instead',
                style: tt.bodySmall?.copyWith(
                  color: AppColors.accentViolet,
                ),
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
