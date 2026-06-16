import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import 'admin_shell.dart';
import 'student_shell.dart';
import 'trainer_shell.dart';

/// Selects the correct role shell after authentication.
class RoleShell extends ConsumerWidget {
  const RoleShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return switch (authState) {
      AuthAuthenticated(:final role) => switch (role) {
          UserRole.admin => const AdminShell(),
          UserRole.trainer => const TrainerShell(),
          UserRole.student => const StudentShell(),
        },
      _ => const Scaffold(
          body: Center(child: ChakraLoader()),
        ),
    };
  }
}
