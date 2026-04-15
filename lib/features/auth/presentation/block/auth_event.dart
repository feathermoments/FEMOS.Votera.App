abstract class AuthEvent {
  const AuthEvent();
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class SendOtpRequested extends AuthEvent {
  const SendOtpRequested({required this.identifier, required this.type});

  final String identifier;
  final String type;
}

class VerifyOtpRequested extends AuthEvent {
  const VerifyOtpRequested({
    required this.identifier,
    required this.type,
    required this.otp,
  });

  final String identifier;
  final String type;
  final String otp;
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
