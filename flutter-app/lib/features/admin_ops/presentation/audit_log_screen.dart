import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../auth/presentation/auth_provider.dart';
import '../domain/audit_log_entry.dart';

final auditLogProvider = FutureProvider<List<AuditLogEntry>>((ref) async {
  final rows = await ref
      .watch(supabaseClientProvider)
      .from('audit_log')
      .select('*, users(id, name)')
      .order('created_at', ascending: false)
      .limit(200);
  return (rows as List<dynamic>)
      .map((r) => AuditLogEntry.fromMap(r as Map<String, dynamic>))
      .toList();
});

/// Admin-only, sensitive actions only (payment verification, role/price
/// changes, suspensions) — not a full activity log of every click.
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(auditLogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: async.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(child: Text('Failed to load audit log: $e')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No sensitive actions logged yet.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(auditLogProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = entries[i];
                return ListTile(
                  title: Text(e.actionLabel),
                  subtitle: Text(
                    '${e.actorName ?? "System"} · ${DateFormat('d MMM yyyy, HH:mm').format(e.createdAt.toLocal())}',
                  ),
                  trailing: Text(
                    e.targetTable,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
