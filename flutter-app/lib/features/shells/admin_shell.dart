import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_provider.dart';
import '../../features/admin_ops/presentation/audit_log_screen.dart';
import '../../features/admin_ops/presentation/trainer_certifications_screen.dart';
import '../../features/admissions/presentation/leads_screen.dart';
import '../../features/analytics/presentation/reports_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/batches/presentation/admin_batches_screen.dart';
import '../../features/batches/presentation/enrollment_requests_screen.dart';
import '../../features/certificates/presentation/admin_certificates_screen.dart';
import '../../features/dashboard/presentation/admin_dashboard_screen.dart';
import '../../features/events/presentation/admin_events_screen.dart';
import '../../features/holidays/presentation/holidays_screen.dart';
import '../../features/leave/presentation/leave_approval_screen.dart';
import '../../features/notifications/presentation/broadcast_screen.dart';
import '../../features/payments/presentation/admin_payments_screen.dart';
import '../../features/plans/presentation/admin_plans_screen.dart';
import '../../features/shared/students_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/fcm_provider.dart';
import '../../shared/widgets/lazy_indexed_stack.dart';
import '../../shared/widgets/notification_bell.dart';
import '../../shared/widgets/third_eye_icon.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _index = 0;

  List<_Tab> _tabs(AppLocalizations l10n) => [
    _Tab(label: l10n.navDashboard, icon: Icons.dashboard_outlined),
    _Tab(label: l10n.navPayments, icon: Icons.account_balance_wallet_outlined),
    _Tab(label: l10n.navAdmissions, icon: Icons.how_to_reg_outlined),
    _Tab(label: l10n.navStudents, icon: Icons.people_outline),
    _Tab(label: l10n.navLeaves, icon: Icons.event_busy_outlined),
    _Tab(label: l10n.navBatches, icon: Icons.groups_outlined),
    _Tab(label: l10n.navCerts, icon: Icons.workspace_premium_outlined),
    _Tab(label: l10n.navReports, icon: Icons.analytics_outlined),
  ];

  static int _targetToIndex(String target) => switch (target) {
    'payments' => 1,
    'admissions' => 2,
    'students' => 3,
    'leaves' => 4,
    'batches' => 5,
    'certificates' => 6,
    'reports' => 7,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(fcmNotificationTapProvider, (_, next) {
      next.whenData((target) {
        if (target == 'events') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AdminEventsScreen()),
          );
        } else if (target == 'holidays') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const HolidaysScreen()),
          );
        } else {
          setState(() => _index = _targetToIndex(target));
        }
      });
    });
    final themeMode = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context)!;
    final tabs = _tabs(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const ThirdEyeIcon(size: 22),
            const SizedBox(width: 8),
            Text(tabs[_index].label),
          ],
        ),
        actions: [
          const NotificationBell(),
          IconButton(
            icon: const Icon(Icons.card_membership_outlined),
            tooltip: 'Plans',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AdminPlansScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.pending_actions_outlined),
            tooltip: 'Enrollment Requests',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EnrollmentRequestsScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            tooltip: 'Broadcast',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BroadcastScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Audit Log',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AuditLogScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.workspace_premium_outlined),
            tooltip: 'Trainer Certifications',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TrainerCertificationsScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.celebration_outlined),
            tooltip: 'Events',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AdminEventsScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.event_outlined),
            tooltip: 'Holidays',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HolidaysScreen()),
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
        children: const [
          AdminDashboardScreen(),
          AdminPaymentsScreen(),
          LeadsScreen(),
          StudentsScreen(),
          LeaveApprovalScreen(),
          AdminBatchesScreen(),
          AdminCertificatesScreen(),
          ReportsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: tabs
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
