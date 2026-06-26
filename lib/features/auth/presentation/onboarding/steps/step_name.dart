import 'package:flutter/material.dart';

import '../onboarding_step_scaffold.dart';

class StepName extends StatelessWidget {
  const StepName({super.key, required this.ctrl});

  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
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
