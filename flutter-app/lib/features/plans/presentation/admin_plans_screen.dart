import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../domain/plan.dart';
import 'plans_provider.dart';

class AdminPlansScreen extends ConsumerWidget {
  const AdminPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(plansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Plans')),
      body: async.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load plans: $e'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(plansProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (plans) => plans.isEmpty
            ? const _EmptyState()
            : RefreshIndicator(
                onRefresh: () => ref.read(plansProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: plans.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) => _PlanTile(plan: plans[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Plan'),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, {Plan? plan}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PlanEditSheet(plan: plan),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.card_membership_outlined,
            size: 72,
            color: AppColors.accentViolet.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text('No plans configured', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Tap + to create a plan students can be enrolled into.',
            style: tt.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends ConsumerWidget {
  const _PlanTile({required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return ListTile(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _PlanEditSheet(plan: plan),
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.accentViolet.withValues(alpha: 0.12),
        child: const Icon(
          Icons.card_membership,
          color: AppColors.accentViolet,
          size: 20,
        ),
      ),
      title: Text(plan.name, style: tt.titleMedium),
      subtitle: Text(
        '₹${plan.price.toStringAsFixed(0)} · ${plan.durationDays}d'
        '${plan.discountPercent > 0 ? " · ${plan.discountPercent.toStringAsFixed(0)}% off" : ""}'
        '${plan.programs.isNotEmpty ? " · ${plan.programs.join(", ")}" : ""}'
        ' · leave cap ${plan.maxLeaveDaysPerMonth}/mo',
      ),
      trailing: Switch(
        value: plan.isActive,
        onChanged: (_) => ref.read(plansProvider.notifier).toggleActive(plan),
      ),
    );
  }
}

class _PlanEditSheet extends ConsumerStatefulWidget {
  const _PlanEditSheet({this.plan});
  final Plan? plan;

  @override
  ConsumerState<_PlanEditSheet> createState() => _PlanEditSheetState();
}

class _PlanEditSheetState extends ConsumerState<_PlanEditSheet> {
  late final _nameCtrl = TextEditingController(text: widget.plan?.name ?? '');
  late final _priceCtrl = TextEditingController(
    text: widget.plan != null ? widget.plan!.price.toStringAsFixed(0) : '',
  );
  late final _durationCtrl = TextEditingController(
    text: widget.plan?.durationDays.toString() ?? '30',
  );
  late final _discountCtrl = TextEditingController(
    text: widget.plan?.discountPercent.toStringAsFixed(0) ?? '0',
  );
  late final _couponCtrl = TextEditingController(
    text: widget.plan?.couponCode ?? '',
  );
  late final _programsCtrl = TextEditingController(
    text: widget.plan?.programs.join(', ') ?? '',
  );
  late final _leaveCapCtrl = TextEditingController(
    text: widget.plan?.maxLeaveDaysPerMonth.toString() ?? '4',
  );
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _discountCtrl.dispose();
    _couponCtrl.dispose();
    _programsCtrl.dispose();
    _leaveCapCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim());
    final duration = int.tryParse(_durationCtrl.text.trim());
    if (name.isEmpty || price == null || duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name, price, and duration are required.'),
        ),
      );
      return;
    }
    final discount = double.tryParse(_discountCtrl.text.trim()) ?? 0;
    final leaveCap = int.tryParse(_leaveCapCtrl.text.trim()) ?? 4;
    final programs = _programsCtrl.text
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    final coupon = _couponCtrl.text.trim();

    setState(() => _saving = true);
    try {
      if (widget.plan == null) {
        await ref
            .read(plansProvider.notifier)
            .create(
              name: name,
              price: price,
              durationDays: duration,
              discountPercent: discount,
              couponCode: coupon.isEmpty ? null : coupon,
              programs: programs,
              maxLeaveDaysPerMonth: leaveCap,
            );
      } else {
        await ref
            .read(plansProvider.notifier)
            .editPlan(
              widget.plan!.id,
              name: name,
              price: price,
              durationDays: duration,
              discountPercent: discount,
              couponCode: coupon.isEmpty ? null : coupon,
              programs: programs,
              maxLeaveDaysPerMonth: leaveCap,
            );
      }
      if (mounted) Navigator.of(context).pop();
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
    final isEdit = widget.plan != null;

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
            Text(isEdit ? 'Edit Plan' : 'Add Plan', style: tt.headlineSmall),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Plan name *',
                hintText: 'e.g. All-Access Monthly',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (₹) *',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (days) *',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Discount %',
                      prefixIcon: Icon(Icons.percent_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _leaveCapCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Leave cap/mo',
                      prefixIcon: Icon(Icons.event_busy_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _couponCtrl,
              decoration: const InputDecoration(
                labelText: 'Coupon code (optional)',
                prefixIcon: Icon(Icons.local_offer_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _programsCtrl,
              decoration: const InputDecoration(
                labelText: 'Programs included (comma-separated)',
                hintText: 'e.g. Yoga, Pilates',
                prefixIcon: Icon(Icons.fitness_center_outlined),
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
                    : Text(isEdit ? 'Save Changes' : 'Add Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
