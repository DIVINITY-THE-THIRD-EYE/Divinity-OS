import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/third_eye_icon.dart';
import '../domain/auth_state.dart' as app_auth;
import 'auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  String get _phone {
    final s = ref.read(authStateProvider);
    return s is app_auth.AuthOtpSent ? s.phone : '';
  }

  Future<void> _verify() async {
    final token = _otpCtrl.text.trim();
    if (token.length != 6) {
      setState(() => _error = 'Enter the 6-digit OTP');
      return;
    }
    setState(() => _error = null);
    await ref
        .read(authStateProvider.notifier)
        .verifyOtp(phone: _phone, token: token);
  }

  Future<void> _resend() async {
    _otpCtrl.clear();
    setState(() => _error = null);
    await ref.read(authStateProvider.notifier).resendOtp(phone: _phone);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is app_auth.AuthLoading;
    final stateError = authState is app_auth.AuthError
        ? authState.message
        : null;
    final displayPhone = authState is app_auth.AuthOtpSent
        ? authState.phone
        : _phone;

    return Scaffold(
      body: Stack(
        children: [
          _Background(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _OtpCard(
                  otpCtrl: _otpCtrl,
                  phone: displayPhone,
                  isLoading: isLoading,
                  error: stateError ?? _error,
                  onVerify: _verify,
                  onResend: _resend,
                  onBack: () => ref.read(authStateProvider.notifier).signOut(),
                ),
              ),
            ),
          ),
          if (isLoading) const LoadingOverlay(message: 'Verifying…'),
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

class _OtpCard extends StatelessWidget {
  const _OtpCard({
    required this.otpCtrl,
    required this.phone,
    required this.isLoading,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
    this.error,
  });

  final TextEditingController otpCtrl;
  final String phone;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onBack;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ThirdEyeIcon(size: 56, color: AppColors.accentViolet),
          const SizedBox(height: 16),
          Text('Enter OTP', style: tt.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'We sent a 6-digit code to',
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
            textAlign: TextAlign.center,
          ),
          Text(
            phone,
            style: tt.bodyMedium?.copyWith(
              color: AppColors.accentViolet,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          if (error != null) ...[
            _ErrorBanner(message: error!),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 28,
              letterSpacing: 12,
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '• • • • • •',
              hintStyle: GoogleFonts.jetBrainsMono(
                fontSize: 24,
                letterSpacing: 12,
                color: AppColors.textMutedDark,
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              if (v.length == 6) onVerify();
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onVerify,
              child: const Text('Verify OTP'),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: [
              TextButton(
                onPressed: isLoading ? null : onResend,
                child: Text(
                  'Resend OTP',
                  style: tt.bodySmall?.copyWith(color: AppColors.accentViolet),
                ),
              ),
              TextButton(
                onPressed: isLoading ? null : onBack,
                child: Text(
                  'Back to Login',
                  style: tt.bodySmall?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
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
