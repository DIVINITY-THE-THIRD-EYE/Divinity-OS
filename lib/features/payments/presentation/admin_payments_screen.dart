import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/payment_record.dart';
import 'payment_provider.dart';
import 'record_payment_sheet.dart';

class AdminPaymentsScreen extends ConsumerWidget {
  const AdminPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allPaymentsProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
                            Column(
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

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});
  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final statusColor = switch (payment.status) {
      PaymentStatus.paid => Colors.green,
      PaymentStatus.pending => Colors.orange,
      PaymentStatus.failed => Colors.red,
      PaymentStatus.refunded => Colors.blue,
    };

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          (payment.studentName ?? '?').substring(0, 1).toUpperCase(),
        ),
      ),
      title: Text(payment.studentName ?? payment.studentId.substring(0, 8)),
      subtitle:
          Text('${payment.amountLabel} · ${payment.method.label} · ${payment.dateLabel}'),
      trailing: Chip(
        label: Text(payment.status.label,
            style: tt.labelSmall?.copyWith(color: statusColor)),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
        backgroundColor: statusColor.withValues(alpha: 0.1),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
