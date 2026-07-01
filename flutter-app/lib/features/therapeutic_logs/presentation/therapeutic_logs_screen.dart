import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../shared/students_screen.dart' show studentsProvider;
import '../domain/therapeutic_log.dart';
import 'therapeutic_log_provider.dart';

class TherapeuticLogsScreen extends ConsumerWidget {
  const TherapeuticLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(trainerLogsProvider);

    return Scaffold(
      body: logsAsync.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load logs: $e'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(trainerLogsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (logs) => logs.isEmpty
            ? _EmptyState(onAdd: () => _showAddSheet(context, ref))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(trainerLogsProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: logs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) => _LogTile(
                    log: logs[i],
                    onDelete: () => _confirmDelete(ctx, ref, logs[i]),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('New Log'),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TherapeuticLog log,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Log'),
        content: Text('Delete this note for ${log.studentName ?? 'student'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(trainerLogsProvider.notifier).remove(log.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AddLogSheet(),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 72,
            color: AppColors.accentViolet.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text('No therapeutic logs yet', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a progress note for a student.',
            style: tt.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('New Log'),
          ),
        ],
      ),
    );
  }
}

// ── Log tile ──────────────────────────────────────────────────────────────────

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log, required this.onDelete});
  final TherapeuticLog log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.accentViolet.withValues(alpha: 0.12),
        child: Text(
          (log.studentName ?? '?')[0].toUpperCase(),
          style: const TextStyle(color: AppColors.accentViolet),
        ),
      ),
      title: Text(log.studentName ?? 'Student'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(log.note, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            log.dateLabel,
            style: tt.labelSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        tooltip: 'Delete',
        onPressed: onDelete,
      ),
    );
  }
}

// ── Add log sheet ─────────────────────────────────────────────────────────────

class _AddLogSheet extends ConsumerStatefulWidget {
  const _AddLogSheet();

  @override
  ConsumerState<_AddLogSheet> createState() => _AddLogSheetState();
}

class _AddLogSheetState extends ConsumerState<_AddLogSheet> {
  final _noteCtrl = TextEditingController();
  String? _selectedStudentId;
  bool _saving = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = _noteCtrl.text.trim();
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a student.')));
      return;
    }
    if (note.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note cannot be empty.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(trainerLogsProvider.notifier)
          .add(studentId: _selectedStudentId!, note: note);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final studentsAsync = ref.watch(studentsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('New Therapeutic Log', style: tt.headlineSmall),
            const SizedBox(height: 24),
            // Student picker
            studentsAsync.when(
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (_, _) => const SizedBox.shrink(),
              data: (students) => DropdownButtonFormField<String>(
                key: ValueKey(_selectedStudentId),
                initialValue: _selectedStudentId,
                decoration: const InputDecoration(
                  labelText: 'Student *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                hint: const Text('Select student'),
                items: students
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedStudentId = v),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Progress note *',
                hintText:
                    'e.g. Good improvement in flexibility. Continues to struggle with...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.sticky_note_2_outlined),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
