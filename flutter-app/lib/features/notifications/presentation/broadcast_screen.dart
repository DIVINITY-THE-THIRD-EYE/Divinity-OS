import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';

class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _target = 'ALL';
  bool _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required.')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      final count = await ref
          .read(supabaseClientProvider)
          .rpc(
            'send_broadcast',
            params: {'p_target': _target, 'p_title': title, 'p_body': body},
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sent to $count recipient(s).')));
        _titleCtrl.clear();
        _bodyCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast Notification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send an in-app notification to everyone, all students, or all trainers at once.',
              style: tt.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ALL', label: Text('Everyone')),
                ButtonSegment(value: 'STUDENTS', label: Text('Students')),
                ButtonSegment(value: 'TRAINERS', label: Text('Trainers')),
              ],
              selected: {_target},
              onSelectionChanged: (s) => setState(() => _target = s.first),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g. Studio closed tomorrow',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message *',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Broadcast'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
