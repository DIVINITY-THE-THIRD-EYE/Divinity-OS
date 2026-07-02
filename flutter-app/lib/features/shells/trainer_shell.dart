import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_provider.dart';
import '../../features/admissions/presentation/leads_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/batches/presentation/batches_screen.dart';
import '../../features/leave/presentation/leave_approval_screen.dart';
import '../../features/payments/presentation/trainer_payments_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/therapeutic_logs/presentation/therapeutic_logs_screen.dart';
import '../../features/trainer/presentation/trainer_dashboard_screen.dart';
import '../../features/workouts/presentation/trainer_workouts_screen.dart';
import '../../services/fcm_provider.dart';
import '../../shared/widgets/lazy_indexed_stack.dart';
import '../../shared/widgets/notification_bell.dart';
import '../../shared/widgets/third_eye_icon.dart';

class TrainerShell extends ConsumerStatefulWidget {
  const TrainerShell({super.key});

  @override
  ConsumerState<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends ConsumerState<TrainerShell> {
  int _index = 0;

  static const _tabs = [
    _Tab(label: 'Dashboard', icon: Icons.dashboard_outlined),
    _Tab(label: 'Leaves', icon: Icons.event_busy_outlined),
    _Tab(label: 'Batches', icon: Icons.groups_outlined),
    _Tab(label: 'Workouts', icon: Icons.fitness_center_outlined),
    _Tab(label: 'Logs', icon: Icons.sticky_note_2_outlined),
    _Tab(label: 'Payments', icon: Icons.receipt_long_outlined),
    _Tab(label: 'Profile', icon: Icons.person_outline),
  ];

  static int _targetToIndex(String target) => switch (target) {
    'leaves' => 1,
    'batches' => 2,
    'workouts' => 3,
    'logs' => 4,
    'payments' => 5,
    'profile' => 6,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(fcmNotificationTapProvider, (_, next) {
      next.whenData(
        (target) => setState(() => _index = _targetToIndex(target)),
      );
    });
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
          const NotificationBell(),
          IconButton(
            icon: const Icon(Icons.how_to_reg_outlined),
            tooltip: 'Leads',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LeadsScreen()),
            ),
          ),
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
      body: LazyIndexedStack(
        index: _index,
        children: [
          const TrainerDashboardScreen(),
          const LeaveApprovalScreen(),
          const BatchesScreen(),
          const TrainerWorkoutsScreen(),
          const TherapeuticLogsScreen(),
          const TrainerPaymentsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(icon: Icon(t.icon), label: t.label),
            )
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
