import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/leave_request.dart';
import 'leave_provider.dart';

/// Shown to both Admin and Trainer. Late/over-cap requests need a human
/// decision — but only Admin can decide (RLS enforces this server-side too).
/// Trainer sees the same list read-only: visibility without approval power,
/// per the confirmed leave-request business rules.
class LeaveApprovalScreen extends ConsumerWidget {
  const LeaveApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingLeaveProvider);
    final isAdmin = ref.watch(currentUserRoleProvider) == UserRole.admin;
    return async.when(
      loading: () => const Center(child: ChakraLoader()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        final pending = requests
            .where((r) => r.status == LeaveStatus.pending)
            .toList();
        if (pending.isEmpty) {
          return const Center(child: Text('No pending leave requests.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: pending.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) =>
              _LeaveApprovalTile(request: pending[i], canDecide: isAdmin),
        );
      },
    );
  }
}

class _LeaveApprovalTile extends ConsumerWidget {
  const _LeaveApprovalTile({required this.request, required this.canDecide});
  final LeaveRequest request;
  final bool canDecide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(request.studentName ?? 'Student'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(request.dateRangeLabel),
          if (request.reason != null)
            Text(request.reason!, style: Theme.of(context).textTheme.bodySmall),
          if (!canDecide)
            Text(
              'Over the leave cap or requested late — awaiting Admin decision.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
        ],
      ),
      isThreeLine: request.reason != null || !canDecide,
      trailing: canDecide
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Approve',
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    final uid = ref.read(currentUserIdProvider) ?? '';
                    _confirm(
                      context,
                      ref,
                      'Approve this leave request?',
                      () => ref
                          .read(pendingLeaveProvider.notifier)
                          .approve(request.id, approvedBy: uid),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Reject',
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () {
                    final uid = ref.read(currentUserIdProvider) ?? '';
                    _confirm(
                      context,
                      ref,
                      'Reject this leave request?',
                      () => ref
                          .read(pendingLeaveProvider.notifier)
                          .reject(request.id, approvedBy: uid),
                    );
                  },
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    String message,
    Future<void> Function() action,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await action();
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
