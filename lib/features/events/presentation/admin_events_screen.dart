import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/event.dart';
import 'event_provider.dart';

/// Admin view: create, edit, publish, and monitor event registrations.
class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load events: $e'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(adminEventsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (events) => events.isEmpty
            ? _EmptyState(onAdd: () => _openEditor(context))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(adminEventsProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  itemCount: events.length,
                  itemBuilder: (ctx, i) =>
                      _AdminEventCard(event: events[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
      ),
    );
  }

  static void _openEditor(BuildContext context, {Event? existing}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EventEditorSheet(existing: existing),
    );
  }
}

class _AdminEventCard extends ConsumerWidget {
  const _AdminEventCard({required this.event});
  final Event event;

  Color _statusColor() => switch (event.status) {
        EventStatus.published => Colors.green,
        EventStatus.draft => Colors.orange,
        EventStatus.cancelled => Colors.red,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(event.title,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(event.status.label,
                      style: tt.labelSmall?.copyWith(color: _statusColor())),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') {
                      AdminEventsScreen._openEditor(context, existing: event);
                    } else if (v == 'delete') {
                      _confirmDelete(context, ref);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            _line(context, Icons.schedule, event.whenLabel),
            if (event.location != null && event.location!.isNotEmpty)
              _line(context, Icons.place_outlined, event.location!),
            _line(
              context,
              Icons.groups_outlined,
              event.capacity == null
                  ? '${event.registrationCount} registered'
                  : '${event.registrationCount} / ${event.capacity} registered',
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 4, right: 8),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      );

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${event.title}"? This removes all '
            '${event.registrationCount} registration(s).'),
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
        await ref.read(adminEventsProvider.notifier).remove(event.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}

// ── Editor sheet (create + edit) ──────────────────────────────────────────────

class _EventEditorSheet extends ConsumerStatefulWidget {
  const _EventEditorSheet({this.existing});
  final Event? existing;

  @override
  ConsumerState<_EventEditorSheet> createState() => _EventEditorSheetState();
}

class _EventEditorSheetState extends ConsumerState<_EventEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _capacityCtrl;
  DateTime? _startsAt;
  EventStatus _status = EventStatus.published;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _capacityCtrl =
        TextEditingController(text: e?.capacity?.toString() ?? '');
    _startsAt = e?.startsAt;
    _status = e?.status ?? EventStatus.published;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt ?? now),
    );
    if (time == null) return;
    setState(() => _startsAt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _snack('Title is required.');
      return;
    }
    if (_startsAt == null) {
      _snack('Please pick a start date & time.');
      return;
    }
    final capacityText = _capacityCtrl.text.trim();
    int? capacity;
    if (capacityText.isNotEmpty) {
      capacity = int.tryParse(capacityText);
      if (capacity == null || capacity <= 0) {
        _snack('Capacity must be a positive number.');
        return;
      }
    }

    final draft = Event(
      id: widget.existing?.id ?? '',
      title: title,
      description: _descCtrl.text,
      location: _locationCtrl.text,
      startsAt: _startsAt!,
      capacity: capacity,
      status: _status,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    setState(() => _saving = true);
    try {
      final notifier = ref.read(adminEventsProvider.notifier);
      if (_isEdit) {
        await notifier.edit(widget.existing!.id, draft);
      } else {
        await notifier.create(draft);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('EEE, d MMM yyyy · h:mm a');
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isEdit ? 'Edit Event' : 'New Event', style: tt.headlineSmall),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickStart,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start date & time *',
                  prefixIcon: Icon(Icons.schedule),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _startsAt != null ? fmt.format(_startsAt!) : 'Select',
                  style: _startsAt == null
                      ? TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _capacityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacity (optional)',
                hintText: 'Leave blank for unlimited',
                prefixIcon: Icon(Icons.event_seat_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<EventStatus>(
              segments: const [
                ButtonSegment(
                    value: EventStatus.published,
                    label: Text('Published'),
                    icon: Icon(Icons.public)),
                ButtonSegment(
                    value: EventStatus.draft,
                    label: Text('Draft'),
                    icon: Icon(Icons.edit_note)),
                ButtonSegment(
                    value: EventStatus.cancelled,
                    label: Text('Cancelled'),
                    icon: Icon(Icons.cancel_outlined)),
              ],
              selected: {_status},
              onSelectionChanged: (s) => setState(() => _status = s.first),
            ),
            const SizedBox(height: 8),
            Text(
              _status == EventStatus.published
                  ? 'Publishing notifies all students.'
                  : 'Only admins can see non-published events.',
              style: tt.bodySmall,
            ),
            const SizedBox(height: 24),
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
                    : Text(_isEdit ? 'Save Changes' : 'Create Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          Icon(Icons.event_outlined,
              size: 72, color: AppColors.accentViolet.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No events yet', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text('Create a workshop, seminar or camp.', style: tt.bodyMedium),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('New Event'),
          ),
        ],
      ),
    );
  }
}
