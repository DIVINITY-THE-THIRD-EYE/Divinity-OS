import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../shared/widgets/third_eye_icon.dart';

/// Temporary stub dashboard rendered for Sessions 0–0.
/// Will be replaced feature by feature in Sessions 2–5.
class HomeStubScreen extends ConsumerWidget {
  const HomeStubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            ThirdEyeIcon(size: 24),
            SizedBox(width: 10),
            Text('Divinity'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () =>
                ref.read(authStateProvider.notifier).signOut(),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ThirdEyeIcon(size: 80, color: AppColors.accentViolet),
            const SizedBox(height: 24),
            Text('Welcome to Divinity', style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Session 0 scaffold — features coming next.',
              style:
                  tt.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
            ),
          ],
        ),
      ),
    );
  }
}
