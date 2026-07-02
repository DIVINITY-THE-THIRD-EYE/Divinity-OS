import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../domain/batch.dart';
import '../domain/enrollment.dart';
import 'batch_provider.dart';
import 'enrollment_provider.dart';

/// Student-facing: browse active batches and request to join one. The
/// request lands PENDING for staff to confirm, or WAITLISTED if the batch
/// is already full (see request_enrollment() RPC, migration 040).
class StudentBatchesScreen extends ConsumerWidget {
  const StudentBatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(batchesProvider);
    final myEnrollmentsAsync = ref.watch(myEnrollmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Join a Batch')),
      body: batchesAsync.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(child: Text('Failed to load batches: $e')),
        data: (batches) {
          final active = batches
              .where((b) => b.status == BatchStatus.active)
              .toList();
          if (active.isEmpty) {
            return const Center(child: Text('No active batches right now.'));
          }
          final myStatus = <String, EnrollmentStatus>{
            for (final e in myEnrollmentsAsync.value ?? const <Enrollment>[])
              e.batchId: e.status,
          };
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(batchesProvider.notifier).refresh();
              ref.invalidate(myEnrollmentsProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: active.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _BatchRequestCard(
                batch: active[i],
                currentStatus: myStatus[active[i].id],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BatchRequestCard extends ConsumerStatefulWidget {
  const _BatchRequestCard({required this.batch, this.currentStatus});
  final Batch batch;
  final EnrollmentStatus? currentStatus;

  @override
  ConsumerState<_BatchRequestCard> createState() => _BatchRequestCardState();
}

class _BatchRequestCardState extends ConsumerState<_BatchRequestCard> {
  bool _requesting = false;
  String? _justRequestedResult;

  Future<void> _request() async {
    setState(() => _requesting = true);
    try {
      final result = await ref
          .read(myEnrollmentsProvider.notifier)
          .request(widget.batch.id);
      if (mounted) setState(() => _justRequestedResult = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final status = widget.currentStatus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.batch.name, style: tt.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.batch.scheduleTime} · Cap. ${widget.batch.capacity}',
                    style: tt.bodySmall,
                  ),
                ],
              ),
            ),
            _trailing(status),
          ],
        ),
      ),
    );
  }

  Widget _trailing(EnrollmentStatus? status) {
    if (_justRequestedResult == 'WAITLISTED') {
      return const Chip(label: Text('Waitlisted'));
    }
    if (status == EnrollmentStatus.confirmed) {
      return const Chip(label: Text('Joined'));
    }
    if (status == EnrollmentStatus.pending ||
        _justRequestedResult == 'PENDING') {
      return const Chip(label: Text('Pending'));
    }
    return FilledButton(
      onPressed: _requesting ? null : _request,
      child: _requesting
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Request to Join'),
    );
  }
}
