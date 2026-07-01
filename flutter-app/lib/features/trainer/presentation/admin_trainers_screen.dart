import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../auth/presentation/auth_provider.dart' show supabaseClientProvider;

// ── Domain ────────────────────────────────────────────────────────────────────

class TrainerSummary {
  const TrainerSummary({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.isActive,
    required this.batchCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final bool isActive;
  final int batchCount;
  final DateTime createdAt;

  TrainerSummary copyWith({bool? isActive}) => TrainerSummary(
    id: id,
    name: name,
    phone: phone,
    email: email,
    isActive: isActive ?? this.isActive,
    batchCount: batchCount,
    createdAt: createdAt,
  );
}

// ── Provider ──────────────────────────────────────────────────────────────────

class AdminTrainersNotifier extends AsyncNotifier<List<TrainerSummary>> {
  @override
  Future<List<TrainerSummary>> build() => _fetch();

  Future<List<TrainerSummary>> _fetch() async {
    final client = ref.read(supabaseClientProvider);
    final users = await client
        .from('users')
        .select()
        .eq('role', 'TRAINER')
        .order('created_at', ascending: false);

    final batches = await client.from('batches').select('trainer_id');
    final batchCounts = <String, int>{};
    for (final row in batches as List<dynamic>) {
      final tid = (row as Map<String, dynamic>)['trainer_id'] as String?;
      if (tid != null) {
        batchCounts[tid] = (batchCounts[tid] ?? 0) + 1;
      }
    }

    return (users as List<dynamic>).map((r) {
      final m = r as Map<String, dynamic>;
      final id = m['id'] as String;
      return TrainerSummary(
        id: id,
        name: m['name'] as String? ?? 'Unnamed',
        phone: m['phone'] as String?,
        email: m['email'] as String?,
        isActive: m['is_active'] as bool? ?? true,
        batchCount: batchCounts[id] ?? 0,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> setActive(String trainerId, bool isActive) async {
    await ref
        .read(supabaseClientProvider)
        .from('users')
        .update({'is_active': isActive})
        .eq('id', trainerId);
    state = AsyncData(
      (state.value ?? [])
          .map((t) => t.id == trainerId ? t.copyWith(isActive: isActive) : t)
          .toList(),
    );
  }
}

final adminTrainersProvider =
    AsyncNotifierProvider<AdminTrainersNotifier, List<TrainerSummary>>(
      AdminTrainersNotifier.new,
    );

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminTrainersScreen extends ConsumerWidget {
  const AdminTrainersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminTrainersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Trainers')),
      body: async.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (trainers) {
          if (trainers.isEmpty) {
            return const Center(child: Text('No trainers yet.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(adminTrainersProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: trainers.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (ctx, i) => _TrainerTile(trainer: trainers[i]),
            ),
          );
        },
      ),
    );
  }
}

class _TrainerTile extends ConsumerWidget {
  const _TrainerTile({required this.trainer});
  final TrainerSummary trainer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: trainer.isActive
            ? AppColors.accentViolet.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.15),
        child: Text(trainer.name[0].toUpperCase()),
      ),
      title: Text(trainer.name),
      subtitle: Text(
        '${trainer.phone ?? trainer.email ?? '—'} · ${trainer.batchCount} batch'
        '${trainer.batchCount == 1 ? '' : 'es'}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(
              trainer.isActive ? 'Active' : 'Inactive',
              style: const TextStyle(fontSize: 11),
            ),
            backgroundColor: (trainer.isActive ? Colors.green : Colors.grey)
                .withValues(alpha: 0.15),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Switch(
            value: trainer.isActive,
            onChanged: (v) => _confirmToggle(context, ref, v),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmToggle(
    BuildContext context,
    WidgetRef ref,
    bool newValue,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(newValue ? 'Activate Trainer' : 'Deactivate Trainer'),
        content: Text(
          newValue
              ? 'Reactivate ${trainer.name}? They will regain access as a trainer.'
              : 'Deactivate ${trainer.name}? Their batches and history are kept, '
                    'but they should be reassigned or paused separately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(newValue ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref
            .read(adminTrainersProvider.notifier)
            .setActive(trainer.id, newValue);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${trainer.name} ${newValue ? 'activated' : 'deactivated'}.',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}
