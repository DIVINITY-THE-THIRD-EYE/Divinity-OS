import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_provider.dart';
import '../../features/attendance/presentation/check_in_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/home/presentation/student_home_screen.dart';
import '../../features/leave/presentation/leave_request_screen.dart';
import '../../features/payments/presentation/payments_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/transformation/presentation/third_eye_dashboard_screen.dart';
import '../../services/fcm_provider.dart';
import '../../shared/widgets/notification_bell.dart';
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
    _Tab(label: 'Third Eye', icon: Icons.self_improvement_outlined),
    _Tab(label: 'Attendance', icon: Icons.check_circle_outline),
    _Tab(label: 'Leaves', icon: Icons.event_busy_outlined),
    _Tab(label: 'Payments', icon: Icons.account_balance_wallet_outlined),
    _Tab(label: 'Profile', icon: Icons.person_outline),
  ];

  static int _targetToIndex(String target) => switch (target) {
        'thirdeye' => 1,
        'attendance' => 2,
        'leaves' => 3,
        'payments' => 4,
        'profile' => 5,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(fcmNotificationTapProvider, (_, next) {
      next.whenData((target) => setState(() => _index = _targetToIndex(target)));
    });
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
          const NotificationBell(),
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
          const StudentHomeScreen(),
          const ThirdEyeDashboardScreen(),
          const CheckInScreen(),
          const MyLeaveScreen(),
          const PaymentsScreen(),
          const ProfileScreen(),
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

