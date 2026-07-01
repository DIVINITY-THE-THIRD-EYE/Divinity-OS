import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../domain/payment_record.dart';
import 'payment_provider.dart';
import 'record_payment_sheet.dart';

class AdminPaymentsScreen extends ConsumerWidget {
  const AdminPaymentsScreen({super.key});

  Future<void> _exportCsv(
    BuildContext context,
    List<PaymentRecord> payments,
  ) async {
    final buf = StringBuffer();
    buf.writeln('Date,Student,Amount,Method,Status,Reference');
    for (final p in payments) {
      final date = DateFormat('yyyy-MM-dd').format(p.paidAt);
      final name = (p.studentName ?? p.studentId).replaceAll(',', ' ');
      final ref = (p.referenceNumber ?? '').replaceAll(',', ' ');
      buf.writeln('$date,$name,${p.amount},${p.method.label},${p.status.label},$ref');
    }
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/payments_$stamp.csv');
    await file.writeAsString(buf.toString());
    if (!context.mounted) return;
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Divinity Payments Export $stamp',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allPaymentsProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (payments) {
          if (payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64,
                      color: AppColors.accentViolet.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No payments recorded yet', style: tt.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Tap + to record a fee payment.',
                      style: tt.bodyMedium
                          ?.copyWith(color: AppColors.textSecondaryDark)),
                ],
              ),
            );
          }

          final totalCollected = payments
              .where((p) => p.status == PaymentStatus.paid)
              .fold(0.0, (sum, p) => sum + p.amount);

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(allPaymentsProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Collected',
                                      style: tt.bodySmall),
                                  Text(
                                    '₹${totalCollected.toStringAsFixed(0)}',
                                    style: tt.headlineMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download_outlined),
                              tooltip: 'Export CSV',
                              onPressed: () => _exportCsv(context, payments),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _PaymentRow(payment: payments[i]),
                    childCount: payments.length,
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Record Payment'),
      ),
    );
  }

  Future<void> _showRecordSheet(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const RecordPaymentSheet(),
      );
}

class _PaymentRow extends ConsumerWidget {
  const _PaymentRow({required this.payment});
  final PaymentRecord payment;

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PaymentDetailsDialog(payment: payment),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final String statusLabel;
    final Color statusColor;
    if (payment.status == PaymentStatus.pending) {
      if (payment.adminApproved) {
        statusLabel = 'Pending Trainer';
        statusColor = Colors.orange;
      } else {
        statusLabel = 'Pending Admin';
        statusColor = Colors.amber;
      }
    } else {
      statusLabel = payment.status.label;
      statusColor = switch (payment.status) {
        PaymentStatus.paid => Colors.green,
        PaymentStatus.failed => Colors.red,
        PaymentStatus.refunded => Colors.blue,
        _ => Colors.orange,
      };
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () => _showDetails(context),
        leading: CircleAvatar(
          child: Text(
            (payment.studentName ?? '?').substring(0, 1).toUpperCase(),
          ),
        ),
        title: Text(payment.studentName ?? payment.studentId.substring(0, 8)),
        subtitle:
            Text('${payment.amountLabel} · ${payment.method.label} · ${payment.dateLabel}'),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Chip(
              label: Text(statusLabel,
                  style: tt.labelSmall?.copyWith(color: statusColor)),
              side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
              backgroundColor: statusColor.withValues(alpha: 0.1),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            if (payment.status == PaymentStatus.pending && !payment.adminApproved)
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ── Payment Details & Verification Dialog ─────────────────────────────────────

class _PaymentDetailsDialog extends ConsumerStatefulWidget {
  const _PaymentDetailsDialog({required this.payment});
  final PaymentRecord payment;

  @override
  ConsumerState<_PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends ConsumerState<_PaymentDetailsDialog> {
  bool _verifying = false;

  Future<void> _approve() async {
    final today = DateTime.now();
    int durationDays = 30;
    if (widget.payment.amount >= 15000) {
      durationDays = 365;
    } else if (widget.payment.amount >= 4000) {
      durationDays = 90;
    }

    final initialDate = today.add(Duration(days: durationDays));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 2)),
      helpText: 'Set Plan Expiration Date',
    );

    if (pickedDate == null) return;

    setState(() => _verifying = true);
    try {
      await ref.read(allPaymentsProvider.notifier).verifyPayment(
            paymentId: widget.payment.id,
            studentId: widget.payment.studentId,
            status: PaymentStatus.paid,
            expirationDate: pickedDate,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment approved and membership activated.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _reject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Payment?'),
        content: const Text('Are you sure you want to mark this transaction request as failed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _verifying = true);
    try {
      await ref.read(allPaymentsProvider.notifier).verifyPayment(
            paymentId: widget.payment.id,
            studentId: widget.payment.studentId,
            status: PaymentStatus.failed,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment request rejected.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final p = widget.payment;
    
    final String statusLabel;
    final Color statusColor;
    if (p.status == PaymentStatus.pending) {
      if (p.adminApproved) {
        statusLabel = 'Pending Trainer';
        statusColor = Colors.orange;
      } else {
        statusLabel = 'Pending Admin';
        statusColor = Colors.amber;
      }
    } else {
      statusLabel = p.status.label;
      statusColor = switch (p.status) {
        PaymentStatus.paid => Colors.green,
        PaymentStatus.failed => Colors.red,
        PaymentStatus.refunded => Colors.blue,
        _ => Colors.orange,
      };
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Details', style: tt.titleLarge),
                Chip(
                  label: Text(statusLabel,
                      style: tt.labelSmall?.copyWith(color: statusColor)),
                  side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 20),

            _detailRow('Student', p.studentName ?? p.studentId, tt),
            _detailRow('Amount', p.amountLabel, tt),
            _detailRow('Payment Method', p.method.label, tt),
            if (p.referenceNumber != null)
              _detailRow('Transaction UTR', p.referenceNumber!, tt, copyable: true),
            _detailRow('Date', p.dateLabel, tt),
            if (p.notes != null) _detailRow('Notes', p.notes!, tt),

            if (p.screenshotUrl != null) ...[
              const SizedBox(height: 20),
              Text('Receipt Screenshot', style: tt.bodySmall?.copyWith(color: AppColors.accentGold)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.02),
                  child: Image.network(
                    p.screenshotUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Failed to load receipt image'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],

            if (p.status == PaymentStatus.pending && !p.adminApproved) ...[
              const SizedBox(height: 28),
              if (_verifying)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.error,
                          side: BorderSide(color: colors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Reject Payment'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _approve,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Approve & Activate'),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, TextTheme tt, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              if (copyable)
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                  },
                ),
            ],
          ),
          const Divider(height: 12, thickness: 0.5),
        ],
      ),
    );
  }
}
