import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../domain/payment_record.dart';
import 'payment_provider.dart';

class TrainerPaymentsScreen extends ConsumerWidget {
  const TrainerPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allPaymentsProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (payments) {
          final pendingTrainer = payments
              .where(
                (p) =>
                    p.adminApproved &&
                    !p.receiptGivenByTrainer &&
                    p.status == PaymentStatus.pending,
              )
              .toList();

          if (pendingTrainer.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_outlined,
                    size: 64,
                    color: AppColors.accentViolet.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text('All clear!', style: tt.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'No payments awaiting trainer confirmation.',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(allPaymentsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: pendingTrainer.length,
              itemBuilder: (ctx, i) =>
                  _TrainerPaymentCard(payment: pendingTrainer[i]),
            ),
          );
        },
      ),
    );
  }
}

class _TrainerPaymentCard extends ConsumerStatefulWidget {
  const _TrainerPaymentCard({required this.payment});
  final PaymentRecord payment;

  @override
  ConsumerState<_TrainerPaymentCard> createState() =>
      _TrainerPaymentCardState();
}

class _TrainerPaymentCardState extends ConsumerState<_TrainerPaymentCard> {
  bool _submitting = false;

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    try {
      await ref
          .read(allPaymentsProvider.notifier)
          .confirmReceipt(widget.payment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment receipt confirmed. Student plan is now active!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showImageDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              Flexible(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final p = widget.payment;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    (p.studentName ?? '?').substring(0, 1).toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.studentName ?? p.studentId.substring(0, 8),
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(p.createdAt),
                        style: tt.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Pending Trainer',
                    style: tt.labelSmall?.copyWith(color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount Paid',
                      style: tt.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.amountLabel,
                      style: tt.titleLarge?.copyWith(
                        color: AppColors.accentViolet,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Payment Method',
                      style: tt.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.method.label,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            if (p.referenceNumber != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction UTR',
                          style: tt.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.referenceNumber!,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: p.referenceNumber!),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied reference number to clipboard'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (p.notes != null) ...[
              Text('Notes', style: tt.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 2),
              Text(p.notes!, style: tt.bodyMedium),
              const SizedBox(height: 12),
            ],
            if (p.screenshotUrl != null) ...[
              InkWell(
                onTap: () => _showImageDialog(context, p.screenshotUrl!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 16,
                        color: AppColors.accentGold,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'View Receipt Screenshot',
                        style: TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _confirm,
                icon: _submitting
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Receipt'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
