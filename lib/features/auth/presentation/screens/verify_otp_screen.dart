import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/l10n/app_localizations.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/widgets/gradient_app_bar.dart';
import 'package:votera_app/features/auth/presentation/block/auth_bloc.dart';
import 'package:votera_app/features/auth/presentation/block/auth_event.dart';
import 'package:votera_app/features/auth/presentation/block/auth_state.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late final String _identifier;
  late final String _type;
  String? _nextRoute;
  Object? _nextArgs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _identifier = args?['identifier'] as String? ?? '';
    _type = args?['type'] as String? ?? 'mobile';
    _nextRoute = args?['nextRoute'] as String?;
    _nextArgs = args?['nextArgs'];
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
    if (_otp.length == 6) _verify(context);
  }

  void _verify(BuildContext ctx) {
    if (_otp.length < 6) return;
    ctx.read<AuthBloc>().add(
      VerifyOtpRequested(identifier: _identifier, type: _type, otp: _otp),
    );
  }

  void _resend(BuildContext ctx) {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    ctx.read<AuthBloc>().add(
      SendOtpRequested(identifier: _identifier, type: _type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated) {
          if (_nextRoute != null) {
            Navigator.pushReplacementNamed(
              ctx,
              _nextRoute!,
              arguments: _nextArgs,
            );
          } else {
            Navigator.pushReplacementNamed(
              ctx,
              RouteNames.dashboard,
              arguments: {
                'isNewUser': state.user.isNewUser,
                'isProfileComplete': state.user.isProfileComplete,
              },
            );
          }
        } else if (state is OtpSent) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(ctx).verifyOtpResendSuccess),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (ctx, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          appBar: GradientAppBar(
            title: AppLocalizations.of(ctx).verifyOtpScreenTitle,
            leading: BackButton(
              color: Colors.white,
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kFormMaxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(
                        Icons.lock_open_rounded,
                        size: 56,
                        color: AppColors.blue,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context).verifyOtpHeading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).verifyOtpSentTo(_identifier),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 36),
                      // ── OTP Digit Boxes ──────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (i) {
                          return SizedBox(
                            width: 48,
                            height: 56,
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              readOnly: isLoading,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.metallicBorder,
                                  ),
                                ),
                              ),
                              onChanged: (v) => _onDigitEntered(i, v),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      // ── Verify Button ────────────────────────────
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _verify(ctx),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context).verifyOtpButton,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ── Resend ───────────────────────────────────
                      Center(
                        child: TextButton(
                          onPressed: isLoading ? null : () => _resend(ctx),
                          child: Text(
                            AppLocalizations.of(context).verifyOtpResendButton,
                            style: const TextStyle(color: AppColors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
