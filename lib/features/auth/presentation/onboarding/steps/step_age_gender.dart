import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../onboarding_constants.dart';
import '../onboarding_step_scaffold.dart';

class StepAgeGender extends StatelessWidget {
  const StepAgeGender({
    super.key,
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
    return OnboardingStepScaffold(
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
              kGenderOptions.length,
              (i) => DropdownMenuItem(
                value: kGenderOptions[i],
                child: Text(kGenderLabels[i]),
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
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
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
