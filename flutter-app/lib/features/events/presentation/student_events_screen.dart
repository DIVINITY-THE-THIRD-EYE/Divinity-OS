import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../payments/domain/payment_record.dart';
import '../../payments/presentation/payment_provider.dart';
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
    if (!widget.event.isRegistered && !widget.event.isFree) {
      // Paid + not yet registered: pay via the same UPI QR + screenshot +
      // Admin verification flow used for memberships (decision #38).
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _EventPaymentSheet(event: widget.event),
      );
      ref.read(studentEventsProvider.notifier).refresh();
      return;
    }

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
            _InfoRow(
              icon: Icons.currency_rupee,
              text: e.isFree ? 'Free' : '₹${e.price?.toStringAsFixed(0)}',
            ),
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
                      label: Text(
                        full
                            ? 'Full'
                            : (e.isFree ? 'Register' : 'Pay & Register'),
                      ),
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

// ── Event payment sheet (reuses the manual UPI QR + screenshot + Admin
// verification flow already built for memberships — decision #38) ──────────

class _EventPaymentSheet extends ConsumerStatefulWidget {
  const _EventPaymentSheet({required this.event});
  final Event event;

  @override
  ConsumerState<_EventPaymentSheet> createState() => _EventPaymentSheetState();
}

class _EventPaymentSheetState extends ConsumerState<_EventPaymentSheet> {
  final _refCtrl = TextEditingController();
  static const _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
  static const _maxFileSizeBytes = 5 * 1024 * 1024;
  XFile? _pickedImage;
  bool _submitting = false;

  @override
  void dispose() {
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Receipt Image'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
    if (source == null) return;
    final image = await picker.pickImage(source: source, imageQuality: 70);
    if (image == null) return;

    final ext = image.name.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      _snack('Invalid file type. Please upload a JPG, PNG, or WebP image.');
      return;
    }
    final bytes = await image.readAsBytes();
    if (bytes.length > _maxFileSizeBytes) {
      _snack('Image is too large. Please upload a file smaller than 5 MB.');
      return;
    }
    setState(() => _pickedImage = image);
  }

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _submit() async {
    if (_refCtrl.text.trim().isEmpty) {
      _snack('Please enter the UPI reference number.');
      return;
    }
    if (_pickedImage == null) {
      _snack('Please upload your payment screenshot.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final bytes = await _pickedImage!.readAsBytes();
      final ext = _pickedImage!.name.split('.').last.toLowerCase();
      final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';

      await ref
          .read(myPaymentsProvider.notifier)
          .submitManualPayment(
            amount: widget.event.price ?? 0,
            method: PaymentMethod.upi,
            referenceNumber: _refCtrl.text.trim(),
            filename: filename,
            bytes: bytes.toList(),
            eventId: widget.event.id,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment submitted! You\'ll be registered once Admin verifies it.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _snack('Submission failed: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
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
            Text('Pay for ${widget.event.title}', style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Amount: ₹${widget.event.price?.toStringAsFixed(0)} · pay via the UPI QR at the studio, then upload your screenshot.',
              style: tt.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _refCtrl,
              inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
              decoration: const InputDecoration(
                labelText: 'UPI reference number',
                prefixIcon: Icon(Icons.tag_outlined),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_outlined),
              label: Text(
                _pickedImage == null
                    ? 'Upload payment screenshot'
                    : 'Screenshot selected ✓',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Payment'),
              ),
            ),
          ],
        ),
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
