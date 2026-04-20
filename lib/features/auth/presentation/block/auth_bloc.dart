import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/core/storage/secure_storage.dart';
import 'package:votera_app/features/auth/domain/entities/user_entity.dart';
import 'package:votera_app/features/auth/domain/repositories/iauth_repository.dart';
import 'package:votera_app/features/auth/presentation/block/auth_event.dart';
import 'package:votera_app/features/auth/presentation/block/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    _repository = sl<IAuthRepository>();
    _storage = sl<SecureStorageService>();
    on<AppStarted>(_onAppStarted);
    on<SendOtpRequested>(_onSendOtp);
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<LogoutRequested>(_onLogout);
  }

  late final IAuthRepository _repository;
  late final SecureStorageService _storage;

  Future<void> _onSendOtp(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.sendOtp(
        identifier: event.identifier,
        type: event.type,
        countryCode: event.countryCode,
      );
      emit(OtpSent(identifier: event.identifier, type: event.type));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.verifyOtp(
        identifier: event.identifier,
        type: event.type,
        otp: event.otp,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty || _isTokenExpired(token)) {
      emit(const AuthUnauthenticated());
      return;
    }
    emit(
      AuthAuthenticated(
        user: UserEntity(
          userId: 0,
          token: token,
          isNewUser: false,
          isProfileComplete: true,
        ),
      ),
    );
  }

  /// Decodes the JWT payload and checks whether the `exp` claim is in the past.
  /// Returns `true` (expired) if the token is malformed or has no `exp`.
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = map['exp'] as int?;
      if (exp == null) return false;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 > exp;
    } catch (_) {
      return true;
    }
  }
}
