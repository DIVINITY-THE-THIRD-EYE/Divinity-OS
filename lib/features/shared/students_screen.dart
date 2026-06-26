import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/auth_provider.dart';
import '../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../transformation/presentation/student_progress_detail_screen.dart';

// ── Domain ────────────────────────────────────────────────────────────────────

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.planStatus,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String planStatus;
  final String role;
  final DateTime createdAt;

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'Unnamed',
        phone: m['phone'] as String?,
        email: m['email'] as String?,
        planStatus: m['plan_status'] as String? ?? 'UNPAID',
        role: m['role'] as String? ?? 'STUDENT',
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}

// ── Provider ──────────────────────────────────────────────────────────────────

class StudentsNotifier extends AsyncNotifier<List<AppUser>> {
  @override
  Future<List<AppUser>> build() => _fetch();

  Future<List<AppUser>> _fetch() async {
    final client = ref.read(supabaseClientProvider);
    final rows = await client
        .from('users')
        .select()
        .eq('role', 'STUDENT')
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => AppUser.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> activatePlan(String userId) async {
    await ref.read(supabaseClientProvider).from('users').update({
      'plan_status': 'ACTIVE',
    }).eq('id', userId);
    state = AsyncData(
      (state.value ?? [])
          .map((u) => u.id == userId
              ? AppUser(
                  id: u.id,
                  name: u.name,
                  phone: u.phone,
                  email: u.email,
                  planStatus: 'ACTIVE',
                  role: u.role,
                  createdAt: u.createdAt,
                )
              : u)
          .toList(),
    );
  }
}

final studentsProvider =
    AsyncNotifierProvider<StudentsNotifier, List<AppUser>>(
  StudentsNotifier.new,
);

// ── Screen ────────────────────────────────────────────────────────────────────

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studentsProvider);
    return async.when(
      loading: () => const Center(child: ChakraLoader()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('No students yet.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(studentsProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (ctx, i) => _StudentTile(user: users[i]),
          ),
        );
      },
    );
  }
}

class _StudentTile extends ConsumerWidget {
  const _StudentTile({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = user.planStatus == 'PENDING_ADMIN';
    final statusColor = _planColor(user.planStatus);

    return ListTile(
      onTap: isPending
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StudentProgressDetailScreen(student: user),
                ),
              ),
      leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
      title: Text(user.name),
      subtitle: Text(user.phone ?? user.email ?? '—'),
      trailing: isPending
          ? FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.orange.shade900,
              ),
              onPressed: () => _confirmActivate(context, ref),
              child: const Text('Activate'),
            )
          : Chip(
              label: Text(
                user.planStatus,
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: statusColor.withValues(alpha: 0.15),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
    );
  }

  Color _planColor(String status) => switch (status.toUpperCase()) {
        'ACTIVE' => Colors.green,
        'PENDING_ADMIN' || 'PENDING_TRAINER' => Colors.orange,
        'PAUSED' => Colors.blue,
        'EXPIRED' => Colors.grey,
        _ => Colors.grey,
      };

  Future<void> _confirmActivate(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Activate Plan'),
        content: Text('Activate plan for ${user.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Activate')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(studentsProvider.notifier).activatePlan(user.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.name}\'s plan activated.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}
