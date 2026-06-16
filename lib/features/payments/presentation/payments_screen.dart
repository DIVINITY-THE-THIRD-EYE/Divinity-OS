import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/payment_record.dart';
import 'payment_provider.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myPaymentsProvider);
    final tt = Theme.of(context).textTheme;

    return async.when(
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
                Text('No payments yet', style: tt.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Your fee receipts will appear here.',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          );
        }

        final totalPaid = payments
            .where((p) => p.status == PaymentStatus.paid)
            .fold(0.0, (sum, p) => sum + p.amount);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _SummaryCard(
                  totalPaid: totalPaid,
                  currency: payments.first.currency,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _PaymentTile(payment: payments[i]),
                childCount: payments.length,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalPaid, required this.currency});
  final double totalPaid;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final label =
        currency == 'INR' ? '₹${totalPaid.toStringAsFixed(0)}' : '$totalPaid';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                color: colors.primary, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Paid', style: tt.bodySmall),
                Text(
                  label,
                  style: tt.headlineMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});
  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final statusColor = switch (payment.status) {
      PaymentStatus.paid => Colors.green,
      PaymentStatus.pending => Colors.orange,
      PaymentStatus.failed => Colors.red,
      PaymentStatus.refunded => Colors.blue,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(_methodIcon(payment.method),
              color: colors.primary, size: 20),
        ),
        title: Text(payment.amountLabel, style: tt.titleMedium),
        subtitle:
            Text('${payment.method.label} · ${payment.dateLabel}'),
        trailing: Chip(
          label: Text(payment.status.label,
              style: tt.labelSmall?.copyWith(color: statusColor)),
          side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
          backgroundColor: statusColor.withValues(alpha: 0.1),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  IconData _methodIcon(PaymentMethod m) => switch (m) {
        PaymentMethod.cash => Icons.money_outlined,
        PaymentMethod.upi => Icons.qr_code_outlined,
        PaymentMethod.bankTransfer => Icons.account_balance_outlined,
        PaymentMethod.razorpay => Icons.payment_outlined,
      };
}
