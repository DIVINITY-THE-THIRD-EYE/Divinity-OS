import 'package:flutter/material.dart';

import '../onboarding_step_scaffold.dart';

class StepEmergencyContact extends StatelessWidget {
  const StepEmergencyContact({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
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
