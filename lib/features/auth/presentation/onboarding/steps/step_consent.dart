import 'package:flutter/material.dart';
import '../onboarding_step_scaffold.dart';

class StepConsent extends StatelessWidget {
  const StepConsent({
    super.key,
    required this.consent,
    required this.onConsentChanged,
  });

  final bool consent;
  final ValueChanged<bool> onConsentChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return OnboardingStepScaffold(
      title: 'Data privacy & consent',
      subtitle: 'Please review and accept our data policy before proceeding.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security_outlined, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(
                      'DPDP Act Compliance',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Under the Digital Personal Data Protection (DPDP) Act, we require your explicit consent to collect and process the following:',
                  style: tt.bodySmall?.copyWith(height: 1.4),
                ),
                const _BulletPoint(
                  icon: Icons.location_on_outlined,
                  text:
                      'Location coordinates to verify presence during geofenced check-ins.',
                ),
                const SizedBox(height: 8),
                const _BulletPoint(
                  icon: Icons.health_and_safety_outlined,
                  text:
                      'Medical conditions or physical injuries to customize your therapeutic and diet plans.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => onConsentChanged(!consent),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: consent
                      ? cs.primary
                      : cs.outline.withValues(alpha: 0.4),
                  width: consent ? 2 : 1,
                ),
                color: consent
                    ? cs.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: consent,
                    onChanged: (val) => onConsentChanged(val ?? false),
                    activeColor: cs.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'I consent to Divinity collecting my location data for geofenced check-ins and health metrics for therapeutic/diet logging.',
                        style: tt.bodyMedium?.copyWith(height: 1.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
