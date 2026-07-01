import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/analytics_service.dart';
import '../../shared/students_screen.dart' show studentsProvider;
import '../domain/payment_record.dart';
import 'payment_provider.dart';

class RecordPaymentSheet extends ConsumerStatefulWidget {
  const RecordPaymentSheet({super.key, this.studentId, this.studentName});

  /// When null the sheet shows a student picker.
  final String? studentId;
  final String? studentName;

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;

  // Only tracks student ID when no studentId passed in from parent.
  String? _pickedStudentId;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _pickedStudentId = widget.studentId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final studentId = _pickedStudentId;
    if (studentId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a student.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final amount = double.parse(_amountCtrl.text.trim());
      await ref
          .read(allPaymentsProvider.notifier)
          .record(
            studentId: studentId,
            amount: amount,
            method: _method,
            referenceNumber: _refCtrl.text.trim().isEmpty
                ? null
                : _refCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );
      unawaited(
        AnalyticsService.logPaymentRecord(
          amount: amount,
          method: _method.dbValue,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
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
      child: DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Record Payment', style: tt.titleLarge),
                  const SizedBox(height: 20),

                  // Student picker — only when no studentId was passed in.
                  if (widget.studentId == null) ...[
                    _StudentPicker(
                      selectedId: _pickedStudentId,
                      onChanged: (id) => setState(() => _pickedStudentId = id),
                    ),
                    const SizedBox(height: 16),
                  ] else if (widget.studentName != null) ...[
                    Text(
                      'Student: ${widget.studentName}',
                      style: tt.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      prefixIcon: Icon(Icons.currency_rupee_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final n = double.tryParse(v);
                      if (n == null) return 'Invalid amount';
                      if (n <= 0) return 'Must be greater than 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // key forces FormField to reinitialize when _method changes.
                  DropdownButtonFormField<PaymentMethod>(
                    key: ValueKey(_method),
                    initialValue: _method,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: Icon(Icons.payment_outlined),
                    ),
                    items:
                        [
                              PaymentMethod.cash,
                              PaymentMethod.upi,
                              PaymentMethod.bankTransfer,
                            ]
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.label),
                              ),
                            )
                            .toList(),
                    onChanged: (m) =>
                        setState(() => _method = m ?? PaymentMethod.cash),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _refCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reference Number (optional)',
                      prefixIcon: Icon(Icons.tag_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Record Payment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Student picker widget ─────────────────────────────────────────────────────

class _StudentPicker extends ConsumerWidget {
  const _StudentPicker({required this.selectedId, required this.onChanged});
  final String? selectedId;
  final void Function(String id) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);

    return studentsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Failed to load students: $e'),
      data: (students) => DropdownButtonFormField<String>(
        key: ValueKey(selectedId),
        initialValue: selectedId,
        decoration: const InputDecoration(
          labelText: 'Student',
          prefixIcon: Icon(Icons.person_outline),
        ),
        hint: const Text('Select student'),
        items: students
            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
            .toList(),
        onChanged: (id) {
          if (id != null) onChanged(id);
        },
        validator: (v) => v == null ? 'Select a student' : null,
      ),
    );
  }
}

// Silence unawaited future lint for fire-and-forget analytics.
void unawaited(Future<void> future) {}
