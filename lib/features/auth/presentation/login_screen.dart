import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/third_eye_icon.dart';
import '../domain/auth_state.dart' as app_auth;
import 'auth_provider.dart';

enum LoginView { providers, emailSignIn, phoneSignIn, signUp }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  LoginView _view = LoginView.providers;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _phoneOtpMode = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final phone = '+91${_phoneCtrl.text.trim()}';
    final name = _nameCtrl.text.trim();

    if (_view == LoginView.emailSignIn) {
      await ref.read(authStateProvider.notifier).signInWithEmail(
            email: email,
            password: password,
          );
    } else if (_view == LoginView.phoneSignIn) {
      if (_phoneOtpMode) {
        await ref.read(authStateProvider.notifier).sendOtp(phone: phone);
      } else {
        await ref.read(authStateProvider.notifier).signInWithPhone(
              phone: phone,
              password: password,
            );
      }
    } else if (_view == LoginView.signUp) {
      await ref.read(authStateProvider.notifier).signUpWithEmail(
            email: email,
            password: password,
            name: name,
            phone: _phoneCtrl.text.trim().isNotEmpty ? phone : null,
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#\$&*~]'))) {
      return 'Must contain at least one special character (!@#\$&*~)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is app_auth.AuthLoading;
    final error = authState is app_auth.AuthError ? authState.message : null;
    final config = ref.watch(authConfigProvider);

    return Scaffold(
      body: Stack(
        children: [
          _Background(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
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
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ThirdEyeIcon(size: 56, color: AppColors.accentViolet),
                        const SizedBox(height: 16),
                        Text('Divinity', style: Theme.of(context).textTheme.headlineMedium),
                        Text(
                          'THE THIRD EYE',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.accentViolet,
                                letterSpacing: 4,
                              ),
                        ),
                        const SizedBox(height: 32),
                        if (error != null) ...[
                          _ErrorBanner(message: error),
                          const SizedBox(height: 16),
                        ],
                        _buildContent(config, isLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            const LoadingOverlay(
              message: 'Connecting…',
            ),
        ],
      ),
    );
  }

  Widget _buildContent(AuthConfig config, bool isLoading) {
    final tt = Theme.of(context).textTheme;

    switch (_view) {
      case LoginView.providers:
        return Column(
          children: [
            if (config.enableGoogleSignIn) ...[
              OutlinedButton(
                onPressed: () => ref.read(authStateProvider.notifier).signInWithGoogle(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.borderDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.surfaceDark,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.png',
                      height: 18,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text('Continue with Google', style: tt.titleSmall),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (config.enableAppleSignIn && Theme.of(context).platform == TargetPlatform.iOS) ...[
              OutlinedButton(
                onPressed: () => ref.read(authStateProvider.notifier).signInWithApple(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.borderDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.surfaceDark,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.apple, size: 18, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Continue with Apple', style: tt.titleSmall),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (config.enableEmailPassword) ...[
              OutlinedButton(
                onPressed: () => setState(() => _view = LoginView.emailSignIn),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.borderDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.surfaceDark,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email_outlined, size: 18, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Continue with Email', style: tt.titleSmall),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (config.enablePhoneOtp) ...[
              OutlinedButton(
                onPressed: () => setState(() => _view = LoginView.phoneSignIn),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.borderDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.surfaceDark,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_outlined, size: 18, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Continue with Phone', style: tt.titleSmall),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            if (config.enableEmailPassword) ...[
              TextButton(
                onPressed: () => setState(() => _view = LoginView.signUp),
                child: Text(
                  'Create Account',
                  style: tt.bodyMedium?.copyWith(color: AppColors.accentViolet, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: _showForgotPasswordDialog,
                child: Text(
                  'Forgot Password?',
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondaryDark),
                ),
              ),
            ]
          ],
        );

      case LoginView.emailSignIn:
        return Column(
          children: [
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? 'Enter a valid email address' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _view = LoginView.providers),
              child: const Text('Use another sign-in method'),
            ),
          ],
        );

      case LoginView.phoneSignIn:
        return Column(
          children: [
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+91 ',
                prefixIcon: Icon(Icons.phone_android_outlined),
                counterText: '',
              ),
              validator: (v) => (v == null || v.length != 10) ? 'Enter a valid 10-digit number' : null,
            ),
            if (!_phoneOtpMode) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => setState(() => _phoneOtpMode = !_phoneOtpMode),
                  child: Text(_phoneOtpMode ? 'Use password instead' : 'Use OTP instead'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: Text(_phoneOtpMode ? 'Send OTP' : 'Sign In'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _view = LoginView.providers),
              child: const Text('Use another sign-in method'),
            ),
          ],
        );

      case LoginView.signUp:
        return Column(
          children: [
            TextFormField(
              controller: _nameCtrl,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your full name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? 'Enter a valid email address' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                prefixText: '+91 ',
                prefixIcon: Icon(Icons.phone_android_outlined),
                counterText: '',
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty && v.length != 10) {
                  return 'Enter a valid 10-digit number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscurePassword,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock_reset_outlined),
              ),
              validator: (v) => (v != _passwordCtrl.text) ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: const Text('Create Account'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _view = LoginView.providers),
              child: const Text('Already have an account? Sign In'),
            ),
          ],
        );
    }
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
