import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/certificate.dart';
import 'certificate_provider.dart';

class AdminCertificatesScreen extends ConsumerWidget {
  const AdminCertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allCertificatesProvider);

    return Scaffold(
      body: allAsync.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text('Failed to load certificates'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(allCertificatesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (rows) => rows.isEmpty
            ? _EmptyState(onIssue: () => _showIssueSheet(context, ref))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(allCertificatesProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _CertificateCard(
                    row: rows[i],
                    onRevoke: () => _confirmRevoke(
                      context,
                      ref,
                      rows[i]['id'] as String,
                      rows[i]['code'] as String,
                    ),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showIssueSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Issue'),
      ),
    );
  }

  Future<void> _confirmRevoke(
    BuildContext context,
    WidgetRef ref,
    String id,
    String code,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Revoke certificate?'),
        content: Text(
          'This will permanently delete certificate $code. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(certificateRepositoryProvider).revoke(id);
      ref.invalidate(allCertificatesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Certificate revoked.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showIssueSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _IssueCertificateSheet(),
    );
  }
}

// ── Certificate card ──────────────────────────────────────────────────────────

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.row, required this.onRevoke});
  final Map<String, dynamic> row;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cert = Certificate.fromMap(row);
    final studentName =
        (row['users'] as Map<String, dynamic>?)?['name'] as String? ??
        'Unknown Student';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 18,
                  color: AppColors.accentViolet,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(cert.title, style: tt.titleSmall)),
                _CodeChip(code: cert.code),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              studentName,
              style: tt.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${cert.programme}  ·  ${cert.issuedOnLabel}',
              style: tt.bodySmall,
            ),
            if (cert.notes != null && cert.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                cert.notes!,
                style: tt.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Revoke'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: onRevoke,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  const _CodeChip({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$code copied')));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.accentViolet.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.accentViolet.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: AppColors.accentViolet,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.copy_outlined,
              size: 11,
              color: AppColors.accentViolet,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onIssue});
  final VoidCallback onIssue;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 72,
            color: AppColors.accentViolet.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text('No certificates issued', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Issue the first certificate to a student.',
            style: tt.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onIssue,
            icon: const Icon(Icons.add),
            label: const Text('Issue certificate'),
          ),
        ],
      ),
    );
  }
}

// ── Issue certificate sheet ───────────────────────────────────────────────────

class _IssueCertificateSheet extends ConsumerStatefulWidget {
  const _IssueCertificateSheet();

  @override
  ConsumerState<_IssueCertificateSheet> createState() =>
      _IssueCertificateSheetState();
}

class _IssueCertificateSheetState
    extends ConsumerState<_IssueCertificateSheet> {
  final _studentIdCtrl = TextEditingController();
  final _titleCtrl = TextEditingController(text: 'Certificate of Completion');
  final _programmeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _issuedOn = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _studentIdCtrl.dispose();
    _titleCtrl.dispose();
    _programmeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final studentId = _studentIdCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    final programme = _programmeCtrl.text.trim();

    if (studentId.isEmpty || title.isEmpty || programme.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student ID, Title, and Programme are required.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final issuerId = ref.read(currentUserIdProvider);
      await ref
          .read(issueCertificateNotifierProvider.notifier)
          .issue(
            Certificate(
              id: '',
              studentId: studentId,
              issuedBy: issuerId,
              code: '',
              title: title,
              programme: programme,
              issuedOn: _issuedOn,
              notes: _notesCtrl.text.trim().isEmpty
                  ? null
                  : _notesCtrl.text.trim(),
            ),
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Certificate issued!')));
      }
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
            Text('Issue Certificate', style: tt.headlineSmall),
            const SizedBox(height: 20),
            TextField(
              controller: _studentIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Student ID (UUID) *',
                hintText: 'Paste from Students list',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Certificate title *',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _programmeCtrl,
              decoration: const InputDecoration(
                labelText: 'Programme *',
                hintText: 'e.g. Yoga Foundations',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Issued on:', style: tt.bodyMedium),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _issuedOn,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) setState(() => _issuedOn = d);
                  },
                  child: Text(
                    '${_issuedOn.day}/${_issuedOn.month}/${_issuedOn.year}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                    : const Text('Issue Certificate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
