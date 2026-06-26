import 'package:flutter/material.dart';

import '../onboarding_constants.dart';
import '../onboarding_step_scaffold.dart';

class StepGoal extends StatelessWidget {
  const StepGoal({
    super.key,
    required this.goal,
    required this.onGoal,
  });

  final String? goal;
  final ValueChanged<String?> onGoal;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return OnboardingStepScaffold(
      title: 'Your primary goal',
      subtitle: 'This shapes your transformation path at Divinity.',
      child: Column(
        children: List.generate(kGoalOptions.length, (i) {
          final selected = goal == kGoalOptions[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onGoal(kGoalOptions[i]),
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
                    Text(kGoalLabels[i], style: tt.bodyMedium),
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
