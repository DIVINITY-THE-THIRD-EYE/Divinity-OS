import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/lead.dart';
import 'leads_provider.dart';
import 'trial_attendance_provider.dart';

// ── Palette for pipeline columns ─────────────────────────────────────────────

Color _columnColor(LeadStatus s) => switch (s) {
  LeadStatus.newLead => AppColors.accentViolet,
  LeadStatus.consultation => AppColors.warning,
  LeadStatus.admitted => AppColors.success,
  LeadStatus.lost => AppColors.error,
};

// ── Screen ────────────────────────────────────────────────────────────────────

class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsProvider);
    final authState = ref.watch(authStateProvider);
    final adminId = authState is AuthAuthenticated ? authState.user.id : null;
    final isAdmin = ref.watch(currentUserRoleProvider) == UserRole.admin;

    return Scaffold(
      body: leadsAsync.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text('Failed to load leads'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(leadsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (leads) => _PipelineBoard(leads: leads),
      ),
      floatingActionButton: (adminId == null || !isAdmin)
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddLead(context, ref, adminId),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add Lead'),
            ),
    );
  }

  void _showAddLead(BuildContext context, WidgetRef ref, String adminId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddLeadSheet(adminId: adminId),
    );
  }
}

// ── Pipeline board ────────────────────────────────────────────────────────────

class _PipelineBoard extends StatelessWidget {
  const _PipelineBoard({required this.leads});
  final List<Lead> leads;

  @override
  Widget build(BuildContext context) {
    final columns = [
      LeadStatus.newLead,
      LeadStatus.consultation,
      LeadStatus.admitted,
      LeadStatus.lost,
    ];

    return Row(
      children: columns.map((status) {
        final columnLeads = leads
            .where((l) => l.pipelineStatus == status)
            .toList();
        return Expanded(
          child: _PipelineColumn(status: status, leads: columnLeads),
        );
      }).toList(),
    );
  }
}

class _PipelineColumn extends StatelessWidget {
  const _PipelineColumn({required this.status, required this.leads});
  final LeadStatus status;
  final List<Lead> leads;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = _columnColor(status);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          color: color.withValues(alpha: 0.1),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status.label,
                  style: tt.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${leads.length}',
                style: tt.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(6),
            itemCount: leads.length,
            itemBuilder: (_, i) => _LeadCard(lead: leads[i]),
          ),
        ),
      ],
    );
  }
}

// ── Lead card ─────────────────────────────────────────────────────────────────

class _LeadCard extends ConsumerWidget {
  const _LeadCard({required this.lead});
  final Lead lead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final color = _columnColor(lead.pipelineStatus);
    final next = lead.pipelineStatus.nextStatus;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lead.name,
                style: tt.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (lead.phone != null) ...[
                const SizedBox(height: 2),
                Text(
                  lead.phone!,
                  style: tt.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (lead.source != null) ...[
                const SizedBox(height: 4),
                Text(
                  lead.source!.label,
                  style: tt.labelSmall?.copyWith(
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
              if (next != null || lead.pipelineStatus != LeadStatus.lost) ...[
                const SizedBox(height: 6),
                _ActionRow(lead: lead, next: next),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LeadDetailSheet(lead: lead),
    );
  }
}

class _ActionRow extends ConsumerWidget {
  const _ActionRow({required this.lead, required this.next});
  final Lead lead;
  final LeadStatus? next;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(leadsProvider.notifier);
    return Row(
      children: [
        if (next != null)
          Expanded(
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                textStyle: const TextStyle(fontSize: 11),
              ),
              onPressed: () => notifier.advancePipeline(lead.id, next!),
              child: Text('→ ${next!.label}'),
            ),
          ),
        if (next != null && lead.pipelineStatus != LeadStatus.consultation)
          const SizedBox(width: 4),
        if (lead.pipelineStatus != LeadStatus.admitted &&
            lead.pipelineStatus != LeadStatus.lost) ...[
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => notifier.markLost(lead.id),
            icon: const Icon(Icons.close, size: 16, color: AppColors.error),
            tooltip: 'Mark lost',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }
}

// ── Lead detail sheet ─────────────────────────────────────────────────────────

class _LeadDetailSheet extends ConsumerStatefulWidget {
  const _LeadDetailSheet({required this.lead});
  final Lead lead;

  @override
  ConsumerState<_LeadDetailSheet> createState() => _LeadDetailSheetState();
}

class _LeadDetailSheetState extends ConsumerState<_LeadDetailSheet> {
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.lead.notes ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final lead = widget.lead;

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
            Text(lead.name, style: tt.headlineSmall),
            if (lead.phone != null) ...[
              const SizedBox(height: 4),
              Text(lead.phone!, style: tt.bodyMedium),
            ],
            if (lead.email != null) ...[
              const SizedBox(height: 4),
              Text(lead.email!, style: tt.bodyMedium),
            ],
            if (lead.pipelineStatus != LeadStatus.admitted &&
                lead.pipelineStatus != LeadStatus.lost) ...[
              const SizedBox(height: 12),
              _TrialAttendanceRow(leadId: lead.id),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(leadsProvider.notifier)
                          .updateNotes(lead.id, _notesCtrl.text.trim());
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Save notes'),
                  ),
                ),
                if (lead.pipelineStatus == LeadStatus.consultation) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => _ConvertToMemberSheet(lead: lead),
                        );
                      },
                      child: const Text('Admit'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trial attendance row ──────────────────────────────────────────────────────

class _TrialAttendanceRow extends ConsumerWidget {
  const _TrialAttendanceRow({required this.leadId});
  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(trialAttendanceCountProvider(leadId));
    return Row(
      children: [
        Icon(
          Icons.fitness_center_outlined,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          countAsync.when(
            data: (n) => n == 0
                ? 'No trial classes yet'
                : '$n trial class${n == 1 ? '' : 'es'} attended',
            loading: () => 'Loading…',
            error: (_, _) => 'Trials: —',
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        TextButton(
          onPressed: () async {
            try {
              await ref
                  .read(trialAttendanceRepositoryProvider)
                  .markAttended(leadId);
              ref.invalidate(trialAttendanceCountProvider(leadId));
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          child: const Text('Mark Trial Attended'),
        ),
      ],
    );
  }
}

// ── Convert to member sheet ───────────────────────────────────────────────────

class _ConvertToMemberSheet extends ConsumerStatefulWidget {
  const _ConvertToMemberSheet({required this.lead});
  final Lead lead;

  @override
  ConsumerState<_ConvertToMemberSheet> createState() =>
      _ConvertToMemberSheetState();
}

class _ConvertToMemberSheetState extends ConsumerState<_ConvertToMemberSheet> {
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  bool _converting = false;
  Map<String, dynamic>? _foundUser;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    // Default to searching by phone if available, else email
    _searchCtrl.text = widget.lead.phone ?? widget.lead.email ?? '';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final queryText = _searchCtrl.text.trim();
    if (queryText.isEmpty) return;

    setState(() {
      _searching = true;
      _foundUser = null;
      _searchError = null;
    });
    try {
      final client = ref.read(supabaseClientProvider);
      var builder = client
          .from('users')
          .select('id, name, phone, email, plan_status');

      final isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(queryText);
      final isEmail = queryText.contains('@');

      if (isUuid) {
        builder = builder.eq('id', queryText);
      } else if (isEmail) {
        builder = builder.eq('email', queryText);
      } else {
        final cleanPhone = queryText.replaceAll(RegExp(r'\D'), '');
        builder = builder.or(
          'phone.eq.$queryText,phone.eq.+91$queryText,phone.eq.$cleanPhone,phone.eq.+91$cleanPhone',
        );
      }

      final row = await builder.maybeSingle();
      setState(() {
        _foundUser = row;
        if (row == null) {
          _searchError = 'No registered user matching that identifier.';
        }
      });
    } catch (e) {
      setState(() => _searchError = e.toString());
    } finally {
      setState(() => _searching = false);
    }
  }

  Future<void> _convert() async {
    if (_foundUser == null) return;
    setState(() => _converting = true);
    try {
      await ref
          .read(leadsProvider.notifier)
          .convertToMember(widget.lead.id, _foundUser!['id'] as String);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.lead.name} admitted as a member.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _converting = false);
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
            Text('Admit ${widget.lead.name}', style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Find their registered account by email, phone, or member ID, '
              'then link and activate their membership.',
              style: tt.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'Email, Phone, or Member ID',
                      prefixIcon: Icon(Icons.search_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _searching ? null : _searchUser,
                  child: _searching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Find'),
                ),
              ],
            ),
            if (_searchError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _searchError!,
                        style: tt.bodySmall?.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ask the student to register via the app first, '
                'then return here to link their account.',
                style: tt.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (_foundUser != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _foundUser!['name'] as String? ?? 'User found',
                            style: tt.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_foundUser!['email'] ?? 'No email'} • ${_foundUser!['phone'] ?? 'No phone'}',
                            style: tt.bodySmall,
                          ),
                          Text(
                            'ID: ${_foundUser!['id']}',
                            style: tt.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _converting ? null : _convert,
                  child: _converting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm Admission'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Add lead sheet ────────────────────────────────────────────────────────────

class _AddLeadSheet extends ConsumerStatefulWidget {
  const _AddLeadSheet({required this.adminId});
  final String adminId;

  @override
  ConsumerState<_AddLeadSheet> createState() => _AddLeadSheetState();
}

class _AddLeadSheetState extends ConsumerState<_AddLeadSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _source;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(leadsProvider.notifier)
          .addLead(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
            email: _emailCtrl.text.trim().isEmpty
                ? null
                : _emailCtrl.text.trim(),
            source: _source,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
            createdBy: widget.adminId,
          );
      if (mounted) Navigator.pop(context);
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
            Text('New Lead', style: tt.headlineSmall),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _source,
              decoration: const InputDecoration(labelText: 'Source (optional)'),
              items: LeadSource.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.dbValue,
                      child: Text(s.label),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _source = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
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
                    : const Text('Add Lead'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
