import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/presentation/auth_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../domain/user_profile.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    return profileAsync.when(
      loading: () => const Center(child: ChakraLoader()),
      error: (_, _) => Center(
        child: FilledButton.tonal(
          onPressed: () => ref.invalidate(myProfileProvider),
          child: const Text('Retry'),
        ),
      ),
      data: (profile) => _ProfileBody(profile: profile),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AvatarHeader(profile: profile),
        const SizedBox(height: 16),
        _PlanStatusCard(profile: profile),
        const SizedBox(height: 20),
        _InfoSection(
          title: 'Personal',
          children: [
            _EditableRow(
              label: 'Name',
              value: profile.name,
              icon: Icons.person_outline,
              onTap: () => _editName(context, ref),
            ),
            _InfoRow(
              label: 'Phone',
              value: profile.phone ?? '—',
              icon: Icons.phone_outlined,
            ),
            _InfoRow(
              label: 'Role',
              value: profile.roleLabel,
              icon: Icons.badge_outlined,
            ),
            if (profile.age != null)
              _InfoRow(
                label: 'Age',
                value: '${profile.age}',
                icon: Icons.cake_outlined,
              ),
            if (profile.gender != null)
              _InfoRow(
                label: 'Gender',
                value: profile.genderLabel,
                icon: Icons.wc_outlined,
              ),
          ],
        ),
        if (profile.role.toUpperCase() == 'TRAINER') ...[
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Certifications',
            action: TextButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
              onPressed: () => _editCertifications(context, ref),
            ),
            children: [
              _InfoRow(
                label: 'Status',
                value: profile.certificationsPublished
                    ? 'Published on website'
                    : (profile.certifications == null
                          ? 'Not submitted yet'
                          : 'Pending Admin approval'),
                icon: profile.certificationsPublished
                    ? Icons.public_outlined
                    : Icons.hourglass_empty_outlined,
              ),
              _InfoRow(
                label: 'Details',
                value: profile.certifications ?? '—',
                icon: Icons.workspace_premium_outlined,
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        _InfoSection(
          title: 'Journey',
          children: [
            _InfoRow(
              label: 'Goal',
              value: profile.goalLabel,
              icon: Icons.flag_outlined,
            ),
            _InfoRow(
              label: 'Activity Level',
              value: profile.lifestyleLabel,
              icon: Icons.directions_run_outlined,
            ),
            _StreakTile(profile: profile),
          ],
        ),
        const SizedBox(height: 16),
        _InfoSection(
          title: 'Support & Feedback',
          children: [
            ListTile(
              dense: true,
              leading: Icon(
                Icons.rate_review_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: const Text('My Feedback'),
              trailing: Icon(
                Icons.chevron_right,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => context.push(Routes.feedback),
            ),
            ListTile(
              dense: true,
              leading: Icon(
                Icons.help_outline,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: const Text('Help & Support'),
              trailing: Icon(
                Icons.chevron_right,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => context.push(Routes.support),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoSection(
          title: 'Emergency Contact',
          action: TextButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit'),
            onPressed: () => _editEmergencyContact(context, ref),
          ),
          children: [
            _InfoRow(
              label: 'Name',
              value: profile.emergencyContactName ?? '—',
              icon: Icons.contact_page_outlined,
            ),
            _InfoRow(
              label: 'Phone',
              value: profile.emergencyContactPhone ?? '—',
              icon: Icons.phone_in_talk_outlined,
            ),
          ],
        ),
        if (profile.injuries != null || profile.medicalConditions != null) ...[
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Health',
            children: [
              if (profile.injuries != null)
                _InfoRow(
                  label: 'Injuries',
                  value: profile.injuries!,
                  icon: Icons.healing_outlined,
                ),
              if (profile.medicalConditions != null)
                _InfoRow(
                  label: 'Medical',
                  value: profile.medicalConditions!,
                  icon: Icons.medical_information_outlined,
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.lock_reset_outlined),
          label: const Text('Change Password'),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.primary,
            side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
          ),
          onPressed: () => context.push(Routes.resetPassword),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout_outlined),
          label: const Text('Sign out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.error,
            side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
          ),
          onPressed: () => ref.read(authStateProvider.notifier).signOut(),
        ),
        const SizedBox(height: 8),
        Text(
          'Member since ${_memberSince(profile.createdAt)}',
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────────

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: profile.name);
    final result = await showDialog<String>(
      context: context,
      builder: (_) =>
          _TextDialog(title: 'Edit Name', ctrl: ctrl, label: 'Full name'),
    );
    ctrl.dispose();
    if (result != null && result.trim().isNotEmpty) {
      ref.read(myProfileProvider.notifier).updateName(result.trim());
    }
  }

  Future<void> _editEmergencyContact(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameCtrl = TextEditingController(
      text: profile.emergencyContactName ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: profile.emergencyContactPhone ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Contact name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    phoneCtrl.dispose();

    if (saved == true) {
      ref
          .read(myProfileProvider.notifier)
          .updateEmergencyContact(
            name: nameCtrl.text.trim(),
            phone: phoneCtrl.text.trim(),
          );
    }
  }

  Future<void> _editCertifications(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: profile.certifications ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Certifications'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Certifications, experience, specializations',
            alignLabelWithHint: true,
            hintText:
                'e.g. 500hr RYT, 5 years teaching Hatha & Vinyasa, therapeutic yoga specialist',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Submit for approval'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (saved == true) {
      ref.read(myProfileProvider.notifier).updateCertifications(ctrl.text);
    }
  }

  static String _memberSince(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

// ── Components ────────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.accentViolet.withValues(alpha: 0.15),
          child: Text(
            profile.initials,
            style: tt.headlineMedium?.copyWith(
              color: AppColors.accentViolet,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profile.name,
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        if (profile.phone != null)
          Text(
            profile.phone!,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
      ],
    );
  }
}

class _PlanStatusCard extends ConsumerWidget {
  const _PlanStatusCard({required this.profile});
  final UserProfile profile;

  Future<void> _togglePause(BuildContext context, WidgetRef ref) async {
    final planStatus = profile.planStatus.toUpperCase();
    final isPaused = planStatus == 'PAUSED';

    if (isPaused) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Resume Membership?'),
          content: const Text(
            'Resuming will reactivate your access and extend your membership expiration date by the number of days you were paused.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.success),
              child: const Text('Resume'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref.read(myProfileProvider.notifier).resumeMembership();
      }
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pause Membership?'),
          content: const Text(
            'Pausing your membership halts your expiration date. You won\'t be able to check in to classes until you resume. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.warning),
              child: const Text('Pause'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref.read(myProfileProvider.notifier).pauseMembership();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final color = _statusColor(profile.planStatus);
    final planStatus = profile.planStatus.toUpperCase();
    final canPause = planStatus == 'ACTIVE' || planStatus == 'PAUSED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(profile.planStatus), color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Membership',
                  style: tt.labelSmall?.copyWith(color: color),
                ),
                Text(
                  profile.planStatusLabel,
                  style: tt.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (profile.expirationDate != null && planStatus != 'PAUSED') ...[
            Text(
              'Expires ${_expiryLabel(profile.expirationDate!)}',
              style: tt.labelSmall?.copyWith(color: color),
            ),
            const SizedBox(width: 12),
          ],
          if (canPause)
            IconButton(
              icon: Icon(
                planStatus == 'PAUSED'
                    ? Icons.play_arrow_outlined
                    : Icons.pause_circle_outline,
                color: color,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: planStatus == 'PAUSED'
                  ? 'Resume Membership'
                  : 'Pause Membership',
              onPressed: () => _togglePause(context, ref),
            ),
        ],
      ),
    );
  }

  Color _statusColor(String s) => switch (s.toUpperCase()) {
    'ACTIVE' => AppColors.success,
    'PAUSED' => AppColors.warning,
    'EXPIRED' => AppColors.error,
    _ => AppColors.textSecondaryDark,
  };

  IconData _statusIcon(String s) => switch (s.toUpperCase()) {
    'ACTIVE' => Icons.verified_outlined,
    'PAUSED' => Icons.pause_circle_outline,
    'EXPIRED' => Icons.cancel_outlined,
    _ => Icons.pending_outlined,
  };

  static String _expiryLabel(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.children,
    this.action,
  });
  final String title;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            // ignore: use_null_aware_elements
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(height: 1, indent: 52),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: cs.onSurfaceVariant),
      title: Text(
        label,
        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      subtitle: Text(value, style: tt.bodyMedium),
    );
  }
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(icon, size: 20, color: cs.onSurfaceVariant),
      title: Text(
        label,
        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      subtitle: Text(value, style: tt.bodyMedium),
      trailing: Icon(Icons.edit_outlined, size: 16, color: cs.primary),
    );
  }
}

class _StreakTile extends StatelessWidget {
  const _StreakTile({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: const Icon(
        Icons.local_fire_department_outlined,
        size: 20,
        color: AppColors.warning,
      ),
      title: Text(
        'Streak',
        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      subtitle: Text(
        '${profile.currentStreak} day${profile.currentStreak != 1 ? 's' : ''} current'
        '  ·  '
        '${profile.maxStreak} day${profile.maxStreak != 1 ? 's' : ''} best',
        style: tt.bodyMedium,
      ),
    );
  }
}

class _TextDialog extends StatelessWidget {
  const _TextDialog({
    required this.title,
    required this.ctrl,
    required this.label,
  });
  final String title;
  final TextEditingController ctrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        textCapitalization: TextCapitalization.words,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(ctrl.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
