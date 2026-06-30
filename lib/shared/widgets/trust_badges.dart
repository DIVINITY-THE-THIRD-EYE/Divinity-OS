import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A single trust/assurance signal.
class TrustBadgeItem {
  const TrustBadgeItem(this.icon, this.title, this.detail);
  final IconData icon;
  final String title;
  final String detail;
}

/// Honest, reusable trust signals — mirror the website's assurance band.
/// Drop into any screen (payments, home, certificates) for reassurance.
const List<TrustBadgeItem> kDefaultTrustBadges = [
  TrustBadgeItem(Icons.verified_user_outlined, 'Secure UPI payments',
      'Every payment is verified by our team and receipted.'),
  TrustBadgeItem(Icons.lock_outline, 'Your data stays private',
      'Health and contact details are access-controlled, never sold.'),
  TrustBadgeItem(Icons.workspace_premium_outlined, 'Verifiable certificates',
      'Completion certificates carry a code anyone can verify.'),
  TrustBadgeItem(Icons.groups_outlined, 'Guided in small batches',
      'Hands-on guidance from the founder and instructors.'),
];

class TrustBadges extends StatelessWidget {
  const TrustBadges({
    super.key,
    this.items = kDefaultTrustBadges,
    this.heading = 'Why members trust us',
  });

  final List<TrustBadgeItem> items;
  final String? heading;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.accentViolet.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != null) ...[
            Text(heading!.toUpperCase(),
                style: tt.labelSmall
                    ?.copyWith(letterSpacing: 1.5, color: Colors.grey)),
            const SizedBox(height: 14),
          ],
          ...items.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(b.icon, size: 22, color: AppColors.accentViolet),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.title, style: tt.titleSmall),
                          const SizedBox(height: 2),
                          Text(b.detail,
                              style: tt.bodySmall
                                  ?.copyWith(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
