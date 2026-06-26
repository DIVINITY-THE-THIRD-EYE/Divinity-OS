import 'package:flutter/material.dart';

import '../onboarding_constants.dart';
import '../onboarding_step_scaffold.dart';

class StepHealth extends StatelessWidget {
  const StepHealth({
    super.key,
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
    return OnboardingStepScaffold(
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
              kLifestyleOptions.length,
              (i) => DropdownMenuItem(
                value: kLifestyleOptions[i],
                child: Text(kLifestyleLabels[i]),
              ),
            ),
            onChanged: onLifestyle,
          ),
        ],
      ),
    );
  }
}
