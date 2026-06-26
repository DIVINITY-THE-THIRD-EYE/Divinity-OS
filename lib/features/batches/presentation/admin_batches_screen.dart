import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/analytics_service.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../shared/students_screen.dart';
import '../domain/batch.dart';
import '../domain/enrollment.dart';
import 'batch_provider.dart';
import 'enrollment_provider.dart';

// ── Trainers provider ─────────────────────────────────────────────────────────

final _trainersProvider = FutureProvider<List<AppUser>>((ref) async {
  final rows = await ref.watch(supabaseClientProvider).from('users').select().eq('role', 'TRAINER').order('name');
  return (rows as List<dynamic>)
      .map((r) => AppUser.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ── Admin batches screen ──────────────────────────────────────────────────────

class AdminBatchesScreen extends ConsumerWidget {
  const AdminBatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesProvider);

    return Scaffold(
      body: batchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text('Failed to load batches'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(batchesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (batches) => batches.isEmpty
            ? _EmptyState(onAdd: () => _showCreateSheet(context, ref))
            : RefreshIndicator(
                onRefresh: () => ref.read(batchesProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: batches.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _AdminBatchCard(batch: batches[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Batch'),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _CreateBatchSheet(),
    );
  }
}

// ── Admin batch card ──────────────────────────────────────────────────────────

class _AdminBatchCard extends ConsumerWidget {
  const _AdminBatchCard({required this.batch});
  final Batch batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final trainersAsync = ref.watch(_trainersProvider);
    final statusColor = switch (batch.status) {
      BatchStatus.active => AppColors.success,
      BatchStatus.paused => AppColors.warning,
      BatchStatus.cancelled => AppColors.error,
    };

    final trainerName = trainersAsync.maybeWhen(
      data: (trainers) => trainers
          .where((t) => t.id == batch.trainerId)
          .map((t) => t.name)
          .firstOrNull,
      orElse: () => null,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(batch.name,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                _StatusChip(status: batch.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 6),
            // Schedule
            Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${batch.scheduleTime}  ·  ${batch.daysOfWeek.join(', ')}',
                  style: tt.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.people_outline,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Cap. ${batch.capacity}',
                    style: tt.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
            // Trainer
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.sports_gymnastics_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  trainerName != null
                      ? 'Trainer: $trainerName'
                      : 'No trainer assigned',
                  style: tt.bodySmall?.copyWith(
                    color: trainerName != null ? Colors.grey : AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEnrolSheet(context, ref),
                  icon: const Icon(Icons.people_outline, size: 16),
                  label: const Text('Enrolments'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () => _showEditSheet(context, ref),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEnrolSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EnrolSheet(batch: batch),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EditBatchSheet(batch: batch),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.color});
  final BatchStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
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
          Icon(Icons.groups_outlined,
              size: 72,
              color: AppColors.accentViolet.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No batches yet', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text('Create your first batch.', style: tt.bodyMedium),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Create batch'),
          ),
        ],
      ),
    );
  }
}

// ── Days helpers ──────────────────────────────────────────────────────────────

const _allDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

// ── Create batch sheet (with trainer assignment) ──────────────────────────────

class _CreateBatchSheet extends ConsumerStatefulWidget {
  const _CreateBatchSheet();

  @override
  ConsumerState<_CreateBatchSheet> createState() => _CreateBatchSheetState();
}

class _CreateBatchSheetState extends ConsumerState<_CreateBatchSheet> {
  final _nameCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '06:00');
  final _capacityCtrl = TextEditingController(text: '20');
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController(text: '100');
  final Set<String> _selectedDays = {};
  String? _selectedTrainerId;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _timeCtrl.dispose();
    _capacityCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name is required.')));
      return;
    }
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valid latitude and longitude coordinates are required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final radius = double.tryParse(_radiusCtrl.text.trim()) ?? 100.0;
      final batch = Batch(
        id: '',
        name: name,
        trainerId: _selectedTrainerId,
        scheduleTime: _timeCtrl.text.trim(),
        daysOfWeek: _selectedDays.toList(),
        capacity: int.tryParse(_capacityCtrl.text.trim()) ?? 20,
        status: BatchStatus.active,
        locationLat: lat,
        locationLng: lng,
        radiusMeters: radius,
        createdAt: DateTime.now(),
      );
      await ref.read(batchesProvider.notifier).createBatch(batch);
      unawaited(AnalyticsService.logBatchCreate(batchName: name));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final trainersAsync = ref.watch(_trainersProvider);

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('New Batch', style: tt.headlineSmall),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Batch name *',
                hintText: 'e.g. Morning Yoga',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Time (HH:MM)',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _capacityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Trainer dropdown
            trainersAsync.when(
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (_, _) => const SizedBox.shrink(),
              data: (trainers) => DropdownButtonFormField<String>(
                initialValue: _selectedTrainerId,
                decoration: const InputDecoration(
                  labelText: 'Assign trainer',
                  prefixIcon: Icon(Icons.sports_gymnastics_outlined),
                ),
                items: [
                  const DropdownMenuItem(child: Text('— None —')),
                  ...trainers.map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.name),
                      )),
                ],
                onChanged: (v) => setState(() => _selectedTrainerId = v),
              ),
            ),
            const SizedBox(height: 20),
            Text('Days', style: tt.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(_allDays.length, (i) {
                final day = _allDays[i];
                final selected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(_dayLabels[i]),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  }),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text('Geofence Coordinates', style: tt.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      prefixIcon: Icon(Icons.my_location_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lngCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _radiusCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Radius (metres)',
                prefixIcon: Icon(Icons.radar_outlined),
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
                    : const Text('Create Batch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit batch sheet ──────────────────────────────────────────────────────────

class _EditBatchSheet extends ConsumerStatefulWidget {
  const _EditBatchSheet({required this.batch});
  final Batch batch;

  @override
  ConsumerState<_EditBatchSheet> createState() => _EditBatchSheetState();
}

class _EditBatchSheetState extends ConsumerState<_EditBatchSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _radiusCtrl;
  late Set<String> _selectedDays;
  String? _selectedTrainerId;
  late BatchStatus _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.batch;
    _nameCtrl = TextEditingController(text: b.name);
    _timeCtrl = TextEditingController(text: b.scheduleTime);
    _capacityCtrl = TextEditingController(text: b.capacity.toString());
    _latCtrl = TextEditingController(
        text: b.locationLat?.toString() ?? '');
    _lngCtrl = TextEditingController(
        text: b.locationLng?.toString() ?? '');
    _radiusCtrl = TextEditingController(
        text: b.radiusMeters.toStringAsFixed(0));
    _selectedDays = Set.from(b.daysOfWeek);
    _selectedTrainerId = b.trainerId;
    _status = b.status;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _timeCtrl.dispose();
    _capacityCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name is required.')));
      return;
    }
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valid latitude and longitude coordinates are required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final radius = double.tryParse(_radiusCtrl.text.trim()) ?? 100.0;
      await ref.read(batchesProvider.notifier).updateBatch(
        widget.batch.id,
        {
          'name': name,
          'trainer_id': _selectedTrainerId,
          'schedule_time': _timeCtrl.text.trim(),
          'days_of_week': _selectedDays.toList(),
          'capacity': int.tryParse(_capacityCtrl.text.trim()) ?? 20,
          'status': _status.name.toUpperCase(),
          'location_lat': lat,
          'location_lng': lng,
          'radius_meters': radius,
        },
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final trainersAsync = ref.watch(_trainersProvider);

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Batch', style: tt.headlineSmall),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Batch name *'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Time (HH:MM)',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _capacityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            trainersAsync.when(
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (_, _) => const SizedBox.shrink(),
              data: (trainers) => DropdownButtonFormField<String>(
                initialValue: _selectedTrainerId,
                decoration: const InputDecoration(
                  labelText: 'Trainer',
                  prefixIcon: Icon(Icons.sports_gymnastics_outlined),
                ),
                items: [
                  const DropdownMenuItem(child: Text('— None —')),
                  ...trainers.map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.name),
                      )),
                ],
                onChanged: (v) => setState(() => _selectedTrainerId = v),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BatchStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: BatchStatus.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 16),
            Text('Geofence Coordinates', style: tt.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      prefixIcon: Icon(Icons.my_location_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lngCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _radiusCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Radius (metres)',
                prefixIcon: Icon(Icons.radar_outlined),
              ),
            ),
            const SizedBox(height: 20),
            Text('Days', style: tt.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(_allDays.length, (i) {
                final day = _allDays[i];
                final selected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(_dayLabels[i]),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  }),
                );
              }),
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
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Enrolment management sheet ────────────────────────────────────────────────

class _EnrolSheet extends ConsumerWidget {
  const _EnrolSheet({required this.batch});
  final Batch batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentsAsync = ref.watch(batchEnrollmentsProvider(batch.id));
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: Text('${batch.name} — Enrolments',
                            style: tt.titleMedium)),
                    FilledButton.icon(
                      onPressed: () => _showAddStudentDialog(ctx, ref),
                      icon: const Icon(Icons.person_add_outlined, size: 16),
                      label: const Text('Add'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: enrollmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (enrollments) => enrollments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 48,
                              color: Colors.grey.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text('No students enrolled yet.',
                              style: tt.bodyMedium),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: controller,
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      itemCount: enrollments.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                      itemBuilder: (ctx2, i) => _EnrolmentTile(
                        enrollment: enrollments[i],
                        batchId: batch.id,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddStudentDialog(
      BuildContext context, WidgetRef ref) async {
    final allStudentsAsync = ref.read(studentsProvider);
    final enrolled = ref.read(batchEnrollmentsProvider(batch.id)).value ?? [];
    final enrolledIds = enrolled.map((e) => e.studentId).toSet();

    final students = allStudentsAsync.value ?? [];
    final unenrolled =
        students.where((s) => !enrolledIds.contains(s.id)).toList();

    if (!context.mounted) return;

    if (unenrolled.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All students are already enrolled.')),
      );
      return;
    }

    final selected = await showDialog<AppUser>(
      context: context,
      builder: (_) => _PickStudentDialog(students: unenrolled),
    );

    if (selected != null && context.mounted) {
      try {
        await ref
            .read(batchEnrollmentsProvider(batch.id).notifier)
            .enroll(selected.id);
        unawaited(AnalyticsService.logStudentEnroll(batchId: batch.id));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${selected.name} enrolled.')),
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

class _EnrolmentTile extends ConsumerWidget {
  const _EnrolmentTile(
      {required this.enrollment, required this.batchId});
  final Enrollment enrollment;
  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(enrollment.studentName[0].toUpperCase()),
      ),
      title: Text(enrollment.studentName),
      subtitle: enrollment.studentPhone != null
          ? Text(enrollment.studentPhone!)
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
        tooltip: 'Remove',
        onPressed: () => _confirmRemove(context, ref),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text(
            'Remove ${enrollment.studentName} from this batch?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref
            .read(batchEnrollmentsProvider(batchId).notifier)
            .unenroll(enrollment.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${enrollment.studentName} removed.')),
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

// ── Pick student dialog ───────────────────────────────────────────────────────

class _PickStudentDialog extends StatelessWidget {
  const _PickStudentDialog({required this.students});
  final List<AppUser> students;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Student'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: students.length,
          itemBuilder: (ctx, i) {
            final s = students[i];
            return ListTile(
              leading: CircleAvatar(
                  child: Text(s.name[0].toUpperCase())),
              title: Text(s.name),
              subtitle:
                  Text(s.phone ?? s.email ?? '—'),
              onTap: () => Navigator.of(ctx).pop(s),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// Silence unawaited future lint.
void unawaited(Future<void> future) {}
