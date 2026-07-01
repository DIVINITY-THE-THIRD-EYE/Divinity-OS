import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/third_eye_icon.dart';
import 'auth_provider.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1E1740), AppColors.bgDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ThirdEyeIcon(size: 72, color: AppColors.accentGold),
                  const SizedBox(height: 24),
                  Text('Awaiting Approval', style: tt.headlineSmall),
                  const SizedBox(height: 12),
                  Text(
                    'Your account is being reviewed.\nYour trainer will activate it shortly.',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  OutlinedButton(
                    onPressed: () =>
                        ref.read(authStateProvider.notifier).signOut(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDark),
                      foregroundColor: AppColors.textSecondaryDark,
                    ),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
