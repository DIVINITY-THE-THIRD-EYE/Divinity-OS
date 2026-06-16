import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/batches/presentation/batches_screen.dart';
import '../../features/leave/presentation/leave_approval_screen.dart';
import '../../shared/widgets/third_eye_icon.dart';

class TrainerShell extends ConsumerStatefulWidget {
  const TrainerShell({super.key});

  @override
  ConsumerState<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends ConsumerState<TrainerShell> {
  int _index = 0;

  static const _tabs = [
    _Tab(label: 'Attendance', icon: Icons.check_circle_outline),
    _Tab(label: 'Leaves', icon: Icons.event_busy_outlined),
    _Tab(label: 'Batches', icon: Icons.groups_outlined),
    _Tab(label: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const ThirdEyeIcon(size: 22),
            const SizedBox(width: 8),
            Text(_tabs[_index].label),
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
        children: [
          _StubPage(title: _tabs[0].label, icon: _tabs[0].icon),
          const LeaveApprovalScreen(),
          const BatchesScreen(),
          _StubPage(title: _tabs[3].label, icon: _tabs[3].icon),
        ],
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
