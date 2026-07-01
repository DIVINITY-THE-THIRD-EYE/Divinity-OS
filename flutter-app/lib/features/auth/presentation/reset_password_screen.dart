import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/third_eye_icon.dart';
import '../domain/auth_state.dart' as app_auth;
import 'auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authStateProvider.notifier)
        .updatePassword(_passwordCtrl.text);
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
                child: _ResetCard(
                  formKey: _formKey,
                  passwordCtrl: _passwordCtrl,
                  confirmPasswordCtrl: _confirmPasswordCtrl,
                  obscurePassword: _obscurePassword,
                  isLoading: isLoading,
                  error: error,
                  onTogglePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onSubmit: _submit,
                ),
              ),
            ),
          ),
          if (isLoading) const LoadingOverlay(message: 'Updating password…'),
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
          colors: [Color(0xFF1E1740), AppColors.bgDark],
        ),
      ),
    );
  }
}

class _ResetCard extends StatelessWidget {
  const _ResetCard({
    required this.formKey,
    required this.passwordCtrl,
    required this.confirmPasswordCtrl,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
    this.error,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmPasswordCtrl;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
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
            Text('Reset Password', style: tt.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Set your new secure password.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 32),
            if (error != null) ...[
              _ErrorBanner(message: error!),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: passwordCtrl,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'New Password',
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
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Enter your password';
                }
                if (v.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!v.contains(RegExp(r'[A-Z]'))) {
                  return 'Must contain at least one uppercase letter';
                }
                if (!v.contains(RegExp(r'[a-z]'))) {
                  return 'Must contain at least one lowercase letter';
                }
                if (!v.contains(RegExp(r'[0-9]'))) {
                  return 'Must contain at least one number';
                }
                if (!v.contains(RegExp(r'[!@#\$&*~]'))) {
                  return 'Must contain at least one special character (!@#\$&*~)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordCtrl,
              obscureText: obscurePassword,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              validator: (v) {
                if (v != passwordCtrl.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: const Text('Update Password'),
              ),
            ),
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
