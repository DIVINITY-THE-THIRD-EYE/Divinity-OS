import 'package:supabase_flutter/supabase_flutter.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  AuthAuthenticated(this.user, this.role);
  final User user;
  final UserRole role;
}

final class AuthOtpSent extends AuthState {
  AuthOtpSent(this.phone);
  final String phone;
}

final class AuthNeedsOnboarding extends AuthState {
  AuthNeedsOnboarding(this.user);
  final User user;
}

final class AuthPendingApproval extends AuthState {
  AuthPendingApproval(this.user);
  final User user;
}

final class AuthUnauthenticated extends AuthState {}

final class AuthPasswordRecovery extends AuthState {
  AuthPasswordRecovery(this.user);
  final User user;
}

final class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}

enum UserRole {
  student,
  trainer,
  admin;

  static UserRole fromString(String value) {
    return switch (value.toUpperCase()) {
      'TRAINER' => UserRole.trainer,
      'ADMIN' => UserRole.admin,
      _ => UserRole.student,
    };
  }
}
