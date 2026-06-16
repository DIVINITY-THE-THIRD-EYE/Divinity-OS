import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../domain/auth_state.dart' as app_auth;
import 'auth_provider.dart';

// ── Constants ────────────────────────────────────────────────────────────────

const _totalSteps = 5;

const _genderOptions = ['MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'];
const _genderLabels = ['Male', 'Female', 'Other', 'Prefer not to say'];

const _lifestyleOptions = [
  'SEDENTARY',
  'LIGHTLY_ACTIVE',
  'MODERATELY_ACTIVE',
  'VERY_ACTIVE',
];
const _lifestyleLabels = [
  'Sedentary (desk work)',
  'Lightly active',
  'Moderately active',
  'Very active',
];

const _goalOptions = [
  'WEIGHT_LOSS',
  'STRENGTH',
  'WELLNESS',
  'THERAPEUTIC_RECOVERY',
  'LIFE_TRANSFORMATION',
];
const _goalLabels = [
  'Weight Loss',
  'Strength',
  'Wellness',
  'Therapeutic Recovery',
  'Life Transformation',
];

// ── Wizard ───────────────────────────────────────────────────────────────────

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

  void _next() {
    if (!_validateStep()) return;
    if (_step < _totalSteps - 1) {
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
                content: Text('Emergency contact name and phone required.')),
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
    }
    return true;
  }

  Future<void> _submit() async {
    final data = <String, dynamic>{
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
      'primary_goal': _goal,
    };
    await ref.read(authStateProvider.notifier).completeOnboarding(data);
  }

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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${_step + 1} of $_totalSteps',
                    style: tt.labelMedium?.copyWith(color: cs.primary),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_step + 1) / _totalSteps,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _StepName(ctrl: _nameCtrl),
                  _StepAgeGender(
                    ageCtrl: _ageCtrl,
                    gender: _gender,
                    onGender: (v) => setState(() => _gender = v),
                  ),
                  _StepEmergencyContact(
                    nameCtrl: _ecNameCtrl,
                    phoneCtrl: _ecPhoneCtrl,
                  ),
                  _StepHealth(
                    injuriesCtrl: _injuriesCtrl,
                    medicalCtrl: _medicalCtrl,
                    lifestyle: _lifestyle,
                    onLifestyle: (v) => setState(() => _lifestyle = v),
                  ),
                  _StepGoal(
                    goal: _goal,
                    onGoal: (v) => setState(() => _goal = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _back,
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(
                        _step == _totalSteps - 1 ? 'Complete' : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step widgets ─────────────────────────────────────────────────────────────

class _StepName extends StatelessWidget {
  const _StepName({required this.ctrl});
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'What should we call you?',
      subtitle: 'Your name will appear on your profile and certificates.',
      child: TextField(
        controller: ctrl,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Full name',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
    );
  }
}

class _StepAgeGender extends StatelessWidget {
  const _StepAgeGender({
    required this.ageCtrl,
    required this.gender,
    required this.onGender,
  });
  final TextEditingController ageCtrl;
  final String? gender;
  final ValueChanged<String?> onGender;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return _StepScaffold(
      title: 'A little about you',
      subtitle: 'Age and gender personalise your journey and cannot be '
          'changed after onboarding.',
      child: Column(
        children: [
          TextField(
            controller: ageCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              prefixIcon: Icon(Icons.cake_outlined),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: gender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Icons.wc_outlined),
            ),
            items: List.generate(
              _genderOptions.length,
              (i) => DropdownMenuItem(
                value: _genderOptions[i],
                child: Text(_genderLabels[i]),
              ),
            ),
            onChanged: onGender,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Age and gender are locked after onboarding completes.',
                    style: tt.labelSmall?.copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepEmergencyContact extends StatelessWidget {
  const _StepEmergencyContact({
    required this.nameCtrl,
    required this.phoneCtrl,
  });
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Emergency contact',
      subtitle: 'Who should we contact in case of an emergency?',
      child: Column(
        children: [
          TextField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Contact name',
              prefixIcon: Icon(Icons.contact_page_outlined),
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
    );
  }
}

class _StepHealth extends StatelessWidget {
  const _StepHealth({
    required this.injuriesCtrl,
    required this.medicalCtrl,
    required this.lifestyle,
    required this.onLifestyle,
  });
  final TextEditingController injuriesCtrl;
  final TextEditingController medicalCtrl;
  final String? lifestyle;
  final ValueChanged<String?> onLifestyle;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Health information',
      subtitle: 'Helps your trainer design a safe and effective programme.',
      child: Column(
        children: [
          TextField(
            controller: injuriesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Any injuries? (optional)',
              prefixIcon: Icon(Icons.healing_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: medicalCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Medical conditions? (optional)',
              prefixIcon: Icon(Icons.medical_information_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: lifestyle,
            decoration: const InputDecoration(
              labelText: 'Activity level *',
              prefixIcon: Icon(Icons.directions_run_outlined),
            ),
            items: List.generate(
              _lifestyleOptions.length,
              (i) => DropdownMenuItem(
                value: _lifestyleOptions[i],
                child: Text(_lifestyleLabels[i]),
              ),
            ),
            onChanged: onLifestyle,
          ),
        ],
      ),
    );
  }
}

class _StepGoal extends StatelessWidget {
  const _StepGoal({required this.goal, required this.onGoal});
  final String? goal;
  final ValueChanged<String?> onGoal;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return _StepScaffold(
      title: 'Your primary goal',
      subtitle: 'This shapes your transformation path at Divinity.',
      child: Column(
        children: List.generate(_goalOptions.length, (i) {
          final selected = goal == _goalOptions[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onGoal(_goalOptions[i]),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? cs.primary
                        : cs.outline.withValues(alpha: 0.4),
                    width: selected ? 2 : 1,
                  ),
                  color: selected
                      ? cs.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected ? cs.primary : cs.outline,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(_goalLabels[i], style: tt.bodyMedium),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tt.headlineSmall),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: tt.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}
