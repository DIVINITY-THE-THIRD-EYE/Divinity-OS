import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../shared/widgets/third_eye_icon.dart';

class StudentShell extends ConsumerStatefulWidget {
  const StudentShell({super.key});

  @override
  ConsumerState<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends ConsumerState<StudentShell> {
  int _index = 0;

  static const _tabs = [
    _Tab(label: 'Home', icon: Icons.home_outlined),
    _Tab(label: 'Attendance', icon: Icons.check_circle_outline),
    _Tab(label: 'Progress', icon: Icons.timeline_outlined),
    _Tab(label: 'Payments', icon: Icons.account_balance_wallet_outlined),
    _Tab(label: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            ThirdEyeIcon(size: 22),
            SizedBox(width: 8),
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
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _tabs
            .map((t) => _StubPage(title: t.label, icon: t.icon))
            .toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _Tab {
  const _Tab({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class _StubPage extends StatelessWidget {
  const _StubPage({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.accentViolet.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(title, style: tt.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Coming in a future session.',
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
          ),
        ],
      ),
    );
  }
}
