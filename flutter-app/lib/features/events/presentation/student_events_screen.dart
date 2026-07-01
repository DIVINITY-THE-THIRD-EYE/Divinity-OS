import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../domain/event.dart';
import 'event_provider.dart';

/// Student view: browse published events and register / cancel.
class StudentEventsScreen extends ConsumerWidget {
  const StudentEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studentEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: async.when(
        loading: () => const Center(child: ChakraLoader()),
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
                    ref.read(studentEventsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (events) => events.isEmpty
            ? const _EmptyState()
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(studentEventsProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  itemCount: events.length,
                  itemBuilder: (ctx, i) => _EventCard(event: events[i]),
                ),
              ),
      ),
    );
  }
}

class _EventCard extends ConsumerStatefulWidget {
  const _EventCard({required this.event});
  final Event event;

  @override
  ConsumerState<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<_EventCard> {
  bool _busy = false;

  Future<void> _toggle() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(studentEventsProvider.notifier)
          .toggleRegistration(widget.event);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update registration: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final tt = Theme.of(context).textTheme;
    final registered = e.isRegistered;
    final full = e.isFull && !registered;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accentViolet.withValues(
                    alpha: 0.12,
                  ),
                  child: const Icon(
                    Icons.event,
                    color: AppColors.accentViolet,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.title,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (registered)
                  const Chip(
                    label: Text('Going'),
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(Icons.check, size: 16, color: Colors.green),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.schedule, text: e.whenLabel),
            if (e.location != null && e.location!.isNotEmpty)
              _InfoRow(icon: Icons.place_outlined, text: e.location!),
            if (e.capacity != null)
              _InfoRow(
                icon: Icons.event_seat_outlined,
                text: full
                    ? 'Full'
                    : '${e.seatsLeft} of ${e.capacity} seats left',
              ),
            if (e.description != null && e.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(e.description!, style: tt.bodyMedium),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: registered
                  ? OutlinedButton.icon(
                      onPressed: _busy ? null : _toggle,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Cancel'),
                    )
                  : FilledButton.icon(
                      onPressed: (_busy || full) ? null : _toggle,
                      icon: _busy
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.how_to_reg, size: 18),
                      label: Text(full ? 'Full' : 'Register'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: tt.bodySmall)),
        ],
      ),
    );
  }
}

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
            Icons.event_available_outlined,
            size: 72,
            color: AppColors.accentViolet.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text('No upcoming events', style: tt.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Workshops, seminars and camps will appear here. '
              'You will be notified when new events are announced.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
