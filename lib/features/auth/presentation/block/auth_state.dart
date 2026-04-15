import 'package:votera_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

/// OTP was sent; UI should navigate to the verify-OTP screen.
class OtpSent extends AuthState {
  const OtpSent({required this.identifier, required this.type});

  final String identifier;
  final String type;
}

/// User successfully authenticated.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final UserEntity user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}
