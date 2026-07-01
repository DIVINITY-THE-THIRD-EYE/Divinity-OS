import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../domain/holiday.dart';
import 'holiday_provider.dart';

class HolidaysScreen extends ConsumerWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(holidaysProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Holidays')),
      body: async.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load holidays: $e'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(holidaysProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (holidays) => holidays.isEmpty
            ? const _EmptyState()
            : RefreshIndicator(
                onRefresh: () => ref.read(holidaysProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: holidays.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) => _HolidayTile(
                    holiday: holidays[i],
                    onDelete: () => _confirmDelete(ctx, ref, holidays[i]),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Holiday'),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Holiday h,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Holiday'),
        content: Text('Remove "${h.name}" (${h.dateLabel})?'),
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
        await ref.read(holidaysProvider.notifier).remove(h.id);
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
      builder: (_) => const _AddHolidaySheet(),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_outlined,
            size: 72,
            color: AppColors.accentViolet.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text('No holidays configured', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a holiday. It will appear on student calendars.',
            style: tt.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Holiday tile ──────────────────────────────────────────────────────────────

class _HolidayTile extends StatelessWidget {
  const _HolidayTile({required this.holiday, required this.onDelete});
  final Holiday holiday;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.accentViolet.withValues(alpha: 0.12),
        child: const Icon(Icons.event, color: AppColors.accentViolet, size: 20),
      ),
      title: Text(holiday.name),
      subtitle: Text('${holiday.dayLabel}, ${holiday.dateLabel}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        tooltip: 'Delete',
        onPressed: onDelete,
      ),
    );
  }
}

// ── Add holiday sheet ─────────────────────────────────────────────────────────

class _AddHolidaySheet extends ConsumerStatefulWidget {
  const _AddHolidaySheet();

  @override
  ConsumerState<_AddHolidaySheet> createState() => _AddHolidaySheetState();
}

class _AddHolidaySheetState extends ConsumerState<_AddHolidaySheet> {
  final _nameCtrl = TextEditingController();
  DateTime? _date;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required.')));
      return;
    }
    if (_date == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(holidaysProvider.notifier).add(date: _date!, name: name);
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
    final fmt = DateFormat('d MMM yyyy');

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
            Text('Add Holiday', style: tt.headlineSmall),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Holiday name *',
                hintText: 'e.g. Diwali',
                prefixIcon: Icon(Icons.event_outlined),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _date != null ? fmt.format(_date!) : 'Select date',
                  style: _date == null
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )
                      : null,
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
                    : const Text('Add Holiday'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
