import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/analytics_service.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../domain/auth_state.dart' as app_auth;
import 'auth_provider.dart';
import 'onboarding/onboarding_constants.dart';
import 'onboarding/steps/step_age_gender.dart';
import 'onboarding/steps/step_consent.dart';
import 'onboarding/steps/step_emergency_contact.dart';
import 'onboarding/steps/step_goal.dart';
import 'onboarding/steps/step_health.dart';
import 'onboarding/steps/step_name.dart';

/// Coordinator widget. Owns wizard state and delegates rendering to step
/// widgets in the `onboarding/steps/` sub-package. Step widgets are pure
/// StatelessWidgets — all mutable state lives here.
class OnboardingWizard extends ConsumerStatefulWidget {
  const OnboardingWizard({super.key});

  @override
  ConsumerState<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends ConsumerState<OnboardingWizard> {
  final _pageController = PageController();
  int _step = 0;

  // Step 1 — name
  final _nameCtrl = TextEditingController();

  // Step 2 — age + gender
  final _ageCtrl = TextEditingController();
  String? _gender;

  // Step 3 — emergency contact
  final _ecNameCtrl = TextEditingController();
  final _ecPhoneCtrl = TextEditingController();

  // Step 4 — health
  final _injuriesCtrl = TextEditingController();
  final _medicalCtrl = TextEditingController();
  String? _lifestyle;

  // Step 5 — goal
  String? _goal;

  // Step 6 — data consent
  bool _consent = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _ecNameCtrl.dispose();
    _ecPhoneCtrl.dispose();
    _injuriesCtrl.dispose();
    _medicalCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _next() {
    if (!_validateStep()) return;
    if (_step < kOnboardingTotalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── Validation ──────────────────────────────────────────────────────────────

  bool _validateStep() {
    final messenger = ScaffoldMessenger.of(context);
    switch (_step) {
      case 0:
        if (_nameCtrl.text.trim().isEmpty) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Please enter your name.')),
          );
          return false;
        }
      case 1:
        final age = int.tryParse(_ageCtrl.text.trim());
        if (age == null || age < 10 || age > 100) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Please enter a valid age.')),
          );
          return false;
        }
        if (_gender == null) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Please select your gender.')),
          );
          return false;
        }
      case 2:
        if (_ecNameCtrl.text.trim().isEmpty ||
            _ecPhoneCtrl.text.trim().isEmpty) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Emergency contact name and phone required.'),
            ),
          );
          return false;
        }
      case 3:
        if (_lifestyle == null) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Please select your activity level.')),
          );
          return false;
        }
      case 4:
        if (_goal == null) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Please select a primary goal.')),
          );
          return false;
        }
      case 5:
        if (!_consent) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Please consent to our data policy to complete onboarding.',
              ),
            ),
          );
          return false;
        }
    }
    return true;
  }

  // ── Submission ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final goal = _goal ?? '';
    await ref.read(authStateProvider.notifier).completeOnboarding({
      'name': _nameCtrl.text.trim(),
      'age': int.parse(_ageCtrl.text.trim()),
      'gender': _gender,
      'emergency_contact_name': _ecNameCtrl.text.trim(),
      'emergency_contact_phone': _ecPhoneCtrl.text.trim(),
      'injuries': _injuriesCtrl.text.trim().isEmpty
          ? null
          : _injuriesCtrl.text.trim(),
      'medical_conditions': _medicalCtrl.text.trim().isEmpty
          ? null
          : _medicalCtrl.text.trim(),
      'lifestyle_activity': _lifestyle,
      'primary_goal': goal,
    });
    try {
      AnalyticsService.logOnboardingComplete(goal: goal).ignore();
    } catch (_) {}
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final authState = ref.watch(authStateProvider);

    if (authState is app_auth.AuthLoading) {
      return const Scaffold(body: Center(child: ChakraLoader()));
    }
    if (authState is app_auth.AuthError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Something went wrong', style: tt.titleMedium),
                const SizedBox(height: 8),
                if (authState case app_auth.AuthError(:final message))
                  Text(
                    message,
                    style: tt.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ProgressHeader(
              step: _step,
              total: kOnboardingTotalSteps,
              cs: cs,
              tt: tt,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  StepName(ctrl: _nameCtrl),
                  StepAgeGender(
                    ageCtrl: _ageCtrl,
                    gender: _gender,
                    onGender: (v) => setState(() => _gender = v),
                  ),
                  StepEmergencyContact(
                    nameCtrl: _ecNameCtrl,
                    phoneCtrl: _ecPhoneCtrl,
                  ),
                  StepHealth(
                    injuriesCtrl: _injuriesCtrl,
                    medicalCtrl: _medicalCtrl,
                    lifestyle: _lifestyle,
                    onLifestyle: (v) => setState(() => _lifestyle = v),
                  ),
                  StepGoal(
                    goal: _goal,
                    onGoal: (v) => setState(() => _goal = v),
                  ),
                  StepConsent(
                    consent: _consent,
                    onConsentChanged: (v) => setState(() => _consent = v),
                  ),
                ],
              ),
            ),
            _NavigationFooter(
              step: _step,
              total: kOnboardingTotalSteps,
              onBack: _back,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private layout widgets (coordinator-only, not exported) ──────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.step,
    required this.total,
    required this.cs,
    required this.tt,
  });

  final int step;
  final int total;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${step + 1} of $total',
            style: tt.labelMedium?.copyWith(color: cs.primary),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (step + 1) / total,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _NavigationFooter extends StatelessWidget {
  const _NavigationFooter({
    required this.step,
    required this.total,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (step > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: onNext,
              child: Text(step == total - 1 ? 'Complete' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
