import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import 'enrollment_provider.dart';

/// Admin/Trainer: confirm/reject self-service enrollment requests, and
/// (Admin-only) manually pick who gets an open batch spot from the waitlist.
class EnrollmentRequestsScreen extends StatelessWidget {
  const EnrollmentRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enrollment Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Waitlist'),
            ],
          ),
        ),
        body: const TabBarView(children: [_PendingTab(), _WaitlistTab()]),
      ),
    );
  }
}

class _PendingTab extends ConsumerWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingEnrollmentsProvider);
    return async.when(
      loading: () => const Center(child: ChakraLoader()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('No pending enrollment requests.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: requests.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final r = requests[i];
            return ListTile(
              title: Text(r.studentName),
              subtitle: Text(DateFormat('d MMM yyyy').format(r.assignedAt)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Confirm',
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    onPressed: () => ref
                        .read(pendingEnrollmentsProvider.notifier)
                        .respond(r.id, approve: true),
                  ),
                  IconButton(
                    tooltip: 'Reject',
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    onPressed: () => ref
                        .read(pendingEnrollmentsProvider.notifier)
                        .respond(r.id, approve: false),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _WaitlistTab extends ConsumerWidget {
  const _WaitlistTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(waitlistProvider);
    return async.when(
      loading: () => const Center(child: ChakraLoader()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(child: Text('No one is waitlisted.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final w = entries[i];
            return ListTile(
              title: Text(w.studentName),
              subtitle: Text(
                '${w.batchName} · waiting since '
                '${DateFormat('d MMM').format(w.requestedAt)}',
              ),
              trailing: FilledButton(
                onPressed: () async {
                  try {
                    await ref.read(waitlistProvider.notifier).convert(w.id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text('Offer Spot'),
              ),
            );
          },
        );
      },
    );
  }
}
