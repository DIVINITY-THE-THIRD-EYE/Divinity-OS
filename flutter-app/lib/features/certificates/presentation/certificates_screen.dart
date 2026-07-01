import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart' show ChakraLoader;
import '../../../shared/widgets/trust_badges.dart';
import '../domain/certificate.dart';
import 'certificate_provider.dart';

/// Student-facing list of their own completion certificates. Designed to live
/// inside the role shell (which provides the shared AppBar), so no AppBar here.
class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certsAsync = ref.watch(myCertificatesProvider);

    return Scaffold(
      body: certsAsync.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Could not load certificates: $e'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(myCertificatesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (certs) => certs.isEmpty
            ? const _EmptyState()
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(myCertificatesProvider),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final c in certs) ...[
                      _CertificateCard(
                        cert: c,
                        onTap: () => _openCertificate(context, c),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    const TrustBadges(),
                  ],
                ),
              ),
      ),
    );
  }

  void _openCertificate(BuildContext context, Certificate cert) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CertificateView(cert: cert)),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Column(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 72,
              color: AppColors.accentViolet.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text('No certificates yet', style: tt.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Complete a programme and your trainer will issue a verifiable '
              'certificate here.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 40),
        const TrustBadges(),
      ],
    );
  }
}

// ── List card ─────────────────────────────────────────────────────────────────

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.cert, required this.onTap});
  final Certificate cert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.accentViolet.withValues(alpha: 0.12),
          child: const Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.accentViolet,
          ),
        ),
        title: Text(cert.programme, style: tt.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cert.title),
            const SizedBox(height: 2),
            Text(
              'Issued ${cert.issuedOnLabel}  ·  ${cert.code}',
              style: tt.labelSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ── Full certificate view (shareable) ─────────────────────────────────────────

class CertificateView extends StatelessWidget {
  const CertificateView({super.key, required this.cert});
  final Certificate cert;

  Future<void> _share() async {
    await Share.share(
      'I earned my "${cert.programme}" certificate from Divinity — The Third Eye.\n'
      'Verification code: ${cert.code}\n'
      'Anyone can confirm it on the Divinity website under "Verify a certificate".',
      subject: 'Divinity Certificate — ${cert.code}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Share',
            onPressed: _share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.accentViolet.withValues(alpha: 0.4),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 56,
                  color: AppColors.accentViolet,
                ),
                const SizedBox(height: 16),
                Text(
                  'DIVINITY — THE THIRD EYE',
                  style: tt.labelLarge?.copyWith(
                    letterSpacing: 2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  cert.title,
                  textAlign: TextAlign.center,
                  style: tt.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'is proudly awarded for completing',
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  cert.programme,
                  textAlign: TextAlign.center,
                  style: tt.titleLarge?.copyWith(color: AppColors.accentViolet),
                ),
                if (cert.notes != null && cert.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    cert.notes!,
                    textAlign: TextAlign.center,
                    style: tt.bodySmall,
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 12),
                Text('Issued ${cert.issuedOnLabel}', style: tt.bodySmall),
                const SizedBox(height: 4),
                Text(
                  'Verification code',
                  style: tt.labelSmall?.copyWith(color: Colors.grey),
                ),
                SelectableText(
                  cert.code,
                  style: tt.titleMedium?.copyWith(
                    fontFeatures: const [],
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: FilledButton.icon(
          onPressed: _share,
          icon: const Icon(Icons.ios_share),
          label: const Text('Share certificate'),
        ),
      ),
    );
  }
}
