import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../services/fcm_provider.dart';
import '../../shared/widgets/loading_widget.dart';
import 'admin_shell.dart';
import 'student_shell.dart';
import 'trainer_shell.dart';

/// Selects the correct role shell after authentication and starts FCM.
class RoleShell extends ConsumerStatefulWidget {
  const RoleShell({super.key});

  @override
  ConsumerState<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends ConsumerState<RoleShell> {
  bool _fcmStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<AuthState>(authStateProvider, (_, state) {
        if (state is AuthAuthenticated && !_fcmStarted) {
          _fcmStarted = true;
          ref.read(fcmServiceProvider).init().ignore();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
