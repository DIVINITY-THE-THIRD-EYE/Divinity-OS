import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/analytics_service.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../domain/leave_request.dart';
import 'leave_provider.dart';

/// Bottom sheet used from the student check-in screen.
class LeaveRequestSheet extends ConsumerStatefulWidget {
  const LeaveRequestSheet({super.key});

  @override
  ConsumerState<LeaveRequestSheet> createState() => _LeaveRequestSheetState();
}

class _LeaveRequestSheetState extends ConsumerState<LeaveRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _loading = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        if (_startDate != null && picked.isBefore(_startDate!)) return;
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select dates.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref
          .read(myLeaveProvider.notifier)
          .submit(
            startDate: _startDate!,
            endDate: _endDate!,
            reason: _reasonCtrl.text.trim().isEmpty
                ? null
                : _reasonCtrl.text.trim(),
          );
      if (mounted) {
        try {
          AnalyticsService.logLeaveRequestSubmit().ignore();
        } catch (_) {}
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave request submitted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Request Leave',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'From',
                    value: _startDate != null ? fmt.format(_startDate!) : null,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerField(
                    label: 'To',
                    value: _endDate != null ? fmt.format(_endDate!) : null,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const ChakraLoader(size: 20)
                  : const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_month_outlined),
      ),
      child: Text(
        value ?? 'Select',
        style: value == null
            ? const TextStyle(color: AppColors.textSecondaryDark)
            : null,
      ),
    ),
  );
}

// ── Student leave history (full screen, used in student shell) ────────────────

class MyLeaveScreen extends ConsumerWidget {
  const MyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myLeaveProvider);
    return async.when(
      loading: () => const Center(child: ChakraLoader()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('No leave requests yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: requests.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) => _LeaveTile(request: requests[i]),
        );
      },
    );
  }
}

class _LeaveTile extends StatelessWidget {
  const _LeaveTile({required this.request});
  final LeaveRequest request;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(_statusIcon(request.status), color: color, size: 20),
      ),
      title: Text(request.dateRangeLabel),
      subtitle: request.reason != null ? Text(request.reason!) : null,
      trailing: Chip(
        label: Text(request.status.label, style: const TextStyle(fontSize: 11)),
        backgroundColor: color.withValues(alpha: 0.12),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Color _statusColor(LeaveStatus s) => switch (s) {
    LeaveStatus.approved => Colors.green,
    LeaveStatus.rejected => Colors.red,
    LeaveStatus.pending => Colors.orange,
  };

  IconData _statusIcon(LeaveStatus s) => switch (s) {
    LeaveStatus.approved => Icons.check_circle_outline,
    LeaveStatus.rejected => Icons.cancel_outlined,
    LeaveStatus.pending => Icons.hourglass_empty,
  };
}
