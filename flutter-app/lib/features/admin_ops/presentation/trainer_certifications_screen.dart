import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../auth/presentation/auth_provider.dart';

class _TrainerCert {
  const _TrainerCert({
    required this.id,
    required this.name,
    required this.certifications,
    required this.published,
  });
  final String id;
  final String name;
  final String certifications;
  final bool published;

  factory _TrainerCert.fromMap(Map<String, dynamic> m) => _TrainerCert(
    id: m['id'] as String,
    name: m['name'] as String? ?? 'Unnamed',
    certifications: m['certifications'] as String,
    published: m['certifications_published'] as bool? ?? false,
  );
}

final _pendingCertsProvider = FutureProvider<List<_TrainerCert>>((ref) async {
  final rows = await ref
      .watch(supabaseClientProvider)
      .from('users')
      .select('id, name, certifications, certifications_published')
      .eq('role', 'TRAINER')
      .not('certifications', 'is', null)
      .eq('certifications_published', false)
      .order('certifications_submitted_at');
  return (rows as List<dynamic>)
      .map((r) => _TrainerCert.fromMap(r as Map<String, dynamic>))
      .toList();
});

/// Admin-only: review and approve-to-publish trainer-submitted
/// certifications before they appear on the public website.
class TrainerCertificationsScreen extends ConsumerWidget {
  const TrainerCertificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_pendingCertsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Certifications')),
      body: async.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (pending) {
          if (pending.isEmpty) {
            return const Center(child: Text('No submissions awaiting approval.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _CertCard(cert: pending[i]),
          );
        },
      ),
    );
  }
}

class _CertCard extends ConsumerWidget {
  const _CertCard({required this.cert});
  final _TrainerCert cert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cert.name, style: tt.titleMedium),
            const SizedBox(height: 8),
            Text(cert.certifications, style: tt.bodyMedium),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(supabaseClientProvider)
                        .from('users')
                        .update({'certifications_published': true})
                        .eq('id', cert.id);
                    ref.invalidate(_pendingCertsProvider);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text('Approve & Publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
