import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/profile_provider.dart';
import '../domain/payment_record.dart';
import 'payment_provider.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(myPaymentsProvider);
    final profileAsync = ref.watch(myProfileProvider);
    final tt = Theme.of(context).textTheme;

    return profileAsync.when(
      loading: () => const Center(child: ChakraLoader()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (profile) {
        final planStatus = profile.planStatus.toUpperCase();

        return paymentsAsync.when(
          loading: () => const Center(child: ChakraLoader()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (payments) {
            final hasPending =
                planStatus == 'PENDING_ADMIN' ||
                planStatus == 'PENDING_TRAINER';
            final isUnpaidOrExpired =
                planStatus == 'UNPAID' || planStatus == 'EXPIRED';
            final expiresSoon =
                planStatus == 'ACTIVE' &&
                profile.expirationDate != null &&
                !profile.expirationDate!.isBefore(DateTime.now()) &&
                profile.expirationDate!.difference(DateTime.now()).inDays <= 7;

            return CustomScrollView(
              slivers: [
                if (isUnpaidOrExpired)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _UnpaidRenewalCard(profile: profile),
                    ),
                  ),
                if (expiresSoon)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _RenewSoonCard(profile: profile),
                    ),
                  ),
                if (hasPending)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _PendingVerificationCard(
                        payments: payments,
                        planStatus: planStatus,
                      ),
                    ),
                  ),
                if (payments.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: _SummaryCard(
                        totalPaid: payments
                            .where((p) => p.status == PaymentStatus.paid)
                            .fold(0.0, (sum, p) => sum + p.amount),
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
                ] else if (!isUnpaidOrExpired && !hasPending)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: AppColors.accentViolet.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('No payments yet', style: tt.headlineSmall),
                          const SizedBox(height: 8),
                          Text(
                            'Your fee receipts will appear here.',
                            style: tt.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalPaid, required this.currency});
  final double totalPaid;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final label = currency == 'INR'
        ? '₹${totalPaid.toStringAsFixed(0)}'
        : '$totalPaid';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: colors.primary,
              size: 32,
            ),
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

// ── Payment List Tile ──────────────────────────────────────────────────────────

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
          child: Icon(
            _methodIcon(payment.method),
            color: colors.primary,
            size: 20,
          ),
        ),
        title: Text(payment.amountLabel, style: tt.titleMedium),
        subtitle: Text('${payment.method.label} · ${payment.dateLabel}'),
        trailing: Chip(
          label: Text(
            payment.status.label,
            style: tt.labelSmall?.copyWith(color: statusColor),
          ),
          side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
          backgroundColor: statusColor.withValues(alpha: 0.1),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }

  IconData _methodIcon(PaymentMethod m) => switch (m) {
    PaymentMethod.cash => Icons.money_outlined,
    PaymentMethod.upi => Icons.qr_code_outlined,
    PaymentMethod.bankTransfer => Icons.account_balance_outlined,
  };
}

// ── Renew Soon Card (proactive, still ACTIVE) ───────────────────────────────

class _RenewSoonCard extends StatelessWidget {
  const _RenewSoonCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final daysLeft = profile.expirationDate!.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.accentGold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              daysLeft <= 1
                  ? 'Your membership expires tomorrow. Renew now to avoid losing access.'
                  : 'Your membership expires in $daysLeft days. Renew early to avoid any gap.',
              style: tt.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const _UploadPaymentSheet(),
            ),
            child: const Text('Renew'),
          ),
        ],
      ),
    );
  }
}

// ── Unpaid / Renewal Card ─────────────────────────────────────────────────────

class _UnpaidRenewalCard extends StatelessWidget {
  const _UnpaidRenewalCard({required this.profile});
  final UserProfile profile;

  void _openPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _UploadPaymentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isExpired = profile.planStatus.toUpperCase() == 'EXPIRED';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentViolet.withValues(alpha: 0.15),
            AppColors.accentGold.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentViolet.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.accentGold,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isExpired ? 'Membership Expired' : 'No Active Membership',
                style: tt.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isExpired
                ? 'Your access has expired. Please renew your membership to continue attending your batches and tracking your weekly progress.'
                : 'Start your yoga journey at Divinity. Select a plan below and upload your UPI payment screenshot to request activation.',
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentViolet,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.payment_outlined),
              label: Text(
                isExpired ? 'Renew Pass' : 'Pay & Activate Membership',
              ),
              onPressed: () => _openPaymentSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pending Verification Card ─────────────────────────────────────────────────

class _PendingVerificationCard extends StatelessWidget {
  const _PendingVerificationCard({
    required this.payments,
    required this.planStatus,
  });
  final List<PaymentRecord> payments;
  final String planStatus;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pendingPayment = payments.firstWhere(
      (p) => p.status == PaymentStatus.pending,
      orElse: () => payments.first,
    );

    final isPendingTrainer = planStatus == 'PENDING_TRAINER';
    final currentStep = isPendingTrainer ? 2 : 1;

    final bodyText = isPendingTrainer
        ? 'Admin has verified your payment of ${pendingPayment.amountLabel} (${pendingPayment.method.label}). Your trainer must now confirm receipt on-site to activate your account.'
        : 'We are verifying your transaction of ${pendingPayment.amountLabel} (${pendingPayment.method.label}). Once approved by admin, it will go to your trainer for final confirmation.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Verification Pending',
                style: tt.titleMedium?.copyWith(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bodyText,
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
          ),
          const SizedBox(height: 20),
          _Stepper(currentStep: currentStep),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final steps = ['Submitted', 'Admin Approved', 'Active'];
    final tt = Theme.of(context).textTheme;

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isEven) {
          final stepIdx = index ~/ 2;
          final isDone = stepIdx < currentStep;
          final isCurrent = stepIdx == currentStep;
          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isDone
                      ? Colors.green
                      : (isCurrent
                            ? AppColors.accentGold
                            : Colors.grey.shade800),
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${stepIdx + 1}',
                          style: tt.labelSmall?.copyWith(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[stepIdx],
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(
                    color: isDone || isCurrent ? Colors.white : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            width: 24,
            height: 1.5,
            color: Colors.grey.shade800,
            margin: const EdgeInsets.only(bottom: 16),
          );
        }
      }),
    );
  }
}

// ── Upload Payment Bottom Sheet ──────────────────────────────────────────────

class _UploadPaymentSheet extends ConsumerStatefulWidget {
  const _UploadPaymentSheet();

  @override
  ConsumerState<_UploadPaymentSheet> createState() =>
      _UploadPaymentSheetState();
}

class _UploadPaymentSheetState extends ConsumerState<_UploadPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final List<YogaPlan> _plans = const [
    YogaPlan('Monthly Yoga Pass', 2000, '30 Days'),
    YogaPlan('Quarterly Alignment Pass', 5000, '90 Days'),
    YogaPlan('Annual Transformation Pass', 18000, '365 Days'),
  ];

  YogaPlan? _selectedPlan;
  XFile? _pickedImage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedPlan = _plans.first;
    _amountCtrl.text = _selectedPlan!.price.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // Allowed screenshot MIME types / extensions for payment receipts.
  static const _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
  // Maximum allowed upload size: 5 MB.
  static const _maxFileSizeBytes = 5 * 1024 * 1024;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Receipt Image'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
    if (source == null) return;
    final image = await picker.pickImage(
      source: source,
      imageQuality: 70, // Compresses image to save bandwidth/storage
    );
    if (image == null) return;

    // Validate file type.
    final ext = image.name.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid file type. Please upload a JPG, PNG, or WebP image.',
            ),
          ),
        );
      }
      return;
    }

    // Validate file size.
    final bytes = await image.readAsBytes();
    if (bytes.length > _maxFileSizeBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Image is too large. Please upload a file smaller than 5 MB.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _pickedImage = image);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your payment screenshot.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final bytes = await _pickedImage!.readAsBytes();

      // Defense-in-depth: re-validate extension and size at submission time.
      final ext = _pickedImage!.name.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Invalid file type. Please upload a JPG, PNG, or WebP image.',
              ),
            ),
          );
        }
        return;
      }
      if (bytes.length > _maxFileSizeBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Image is too large. Please upload a file smaller than 5 MB.',
              ),
            ),
          );
        }
        return;
      }

      final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final amount = double.parse(_amountCtrl.text.trim());

      await ref
          .read(myPaymentsProvider.notifier)
          .submitManualPayment(
            amount: amount,
            method: PaymentMethod.upi,
            referenceNumber: _refCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
            filename: filename,
            bytes: bytes.toList(),
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment registered successfully! Admin will verify soon.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
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
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
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
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Pay & Activate Membership', style: tt.titleLarge),
                const SizedBox(height: 20),

                // Plan Select
                DropdownButtonFormField<YogaPlan>(
                  initialValue: _selectedPlan,
                  decoration: const InputDecoration(
                    labelText: 'Membership Plan',
                    prefixIcon: Icon(Icons.card_membership_outlined),
                  ),
                  items: _plans
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.name} (₹${p.price.toStringAsFixed(0)})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (p) {
                    if (p != null) {
                      setState(() {
                        _selectedPlan = p;
                        _amountCtrl.text = p.price.toStringAsFixed(0);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountCtrl,
                  enabled: false, // Locked to selected plan price
                  decoration: const InputDecoration(
                    labelText: 'Amount to Pay (₹)',
                    prefixIcon: Icon(Icons.currency_rupee_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // UPI Details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Scan UPI QR to Pay',
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.accentGold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 140,
                        height: 140,
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/payment-qr.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'divinity@upi',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Divinity - The Third Eye Wellness Academy',
                        style: tt.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Image picker
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _pickedImage != null
                            ? AppColors.accentViolet.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.1),
                        style: _pickedImage != null
                            ? BorderStyle.solid
                            : BorderStyle.solid,
                      ),
                    ),
                    child: _pickedImage != null
                        ? Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Screenshot Selected',
                                  style: tt.bodyMedium?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                size: 36,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload Payment Screenshot',
                                style: tt.bodyMedium,
                              ),
                              Text(
                                'JPEG, PNG receipts only',
                                style: tt.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // UTR
                TextFormField(
                  controller: _refCtrl,
                  decoration: const InputDecoration(
                    labelText: 'UTR / Transaction Reference (12 digits)',
                    prefixIcon: Icon(Icons.tag_outlined),
                    hintText: 'Enter 12-digit UPI reference',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length != 12) return 'Must be exactly 12 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentViolet,
                    ),
                    child: _submitting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit Payment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class YogaPlan {
  final String name;
  final double price;
  final String duration;
  const YogaPlan(this.name, this.price, this.duration);
}
