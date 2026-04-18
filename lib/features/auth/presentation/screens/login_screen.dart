import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/l10n/app_localizations.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/features/auth/presentation/block/auth_bloc.dart';
import 'package:votera_app/features/auth/presentation/block/auth_event.dart';
import 'package:votera_app/features/auth/presentation/block/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  String _type = 'email';

  // Optional post-auth redirect injected via route arguments.
  String? _nextRoute;
  Object? _nextArgs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _nextRoute = args?['nextRoute'] as String?;
    _nextArgs = args?['nextArgs'];
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is OtpSent) {
            Navigator.pushNamed(
              ctx,
              RouteNames.verifyOtp,
              arguments: {
                'identifier': state.identifier,
                'type': state.type,
                if (_nextRoute != null) 'nextRoute': _nextRoute,
                if (_nextArgs != null) 'nextArgs': _nextArgs,
              },
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
          return Scaffold(
            body: SafeArea(
              child: ctx.isWide
                  ? _WideLayout(
                      formKey: _formKey,
                      identifierCtrl: _identifierCtrl,
                      type: _type,
                      state: state,
                      ctx: ctx,
                      onTypeChanged: (t) {
                        setState(() => _type = t);
                        _identifierCtrl.clear();
                        _formKey.currentState?.reset();
                      },
                      onSubmit: () => _submit(ctx, state),
                    )
                  : _FormBody(
                      formKey: _formKey,
                      identifierCtrl: _identifierCtrl,
                      type: _type,
                      state: state,
                      ctx: ctx,
                      onTypeChanged: (t) {
                        setState(() => _type = t);
                        _identifierCtrl.clear();
                        _formKey.currentState?.reset();
                      },
                      onSubmit: () => _submit(ctx, state),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext ctx, AuthState state) {
    if (state is AuthLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      ctx.read<AuthBloc>().add(
        SendOtpRequested(identifier: _identifierCtrl.text.trim(), type: _type),
      );
    }
  }
}

// ── Wide (tablet / desktop) layout ────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.formKey,
    required this.identifierCtrl,
    required this.type,
    required this.state,
    required this.ctx,
    required this.onTypeChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierCtrl;
  final String type;
  final AuthState state;
  final BuildContext ctx;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Brand panel ──────────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: const BoxDecoration(gradient: AppColors.blueGradient),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.how_to_vote_rounded,
                          color: Colors.white,
                          size: 80,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.appName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.appTagline,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // ── Form panel ───────────────────────────────────────────────
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kFormMaxWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 32,
                ),
                child: _FormBody(
                  formKey: formKey,
                  identifierCtrl: identifierCtrl,
                  type: type,
                  state: state,
                  ctx: ctx,
                  onTypeChanged: onTypeChanged,
                  onSubmit: onSubmit,
                  hideBranding: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Form body (shared between mobile and wide layout) ─────────────────────────

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.formKey,
    required this.identifierCtrl,
    required this.type,
    required this.state,
    required this.ctx,
    required this.onTypeChanged,
    required this.onSubmit,
    this.hideBranding = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierCtrl;
  final String type;
  final AuthState state;
  final BuildContext ctx;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onSubmit;
  final bool hideBranding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: hideBranding
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kFormMaxWidth),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!hideBranding) ...[
                  const SizedBox(height: 48),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blue.withAlpha(60),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.how_to_vote_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                if (hideBranding) ...[
                  Text(
                    l10n.loginSignIn,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 44),
                // ── Contact Type Selector ─────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _TypeChip(
                        label: l10n.loginTypeEmail,
                        selected: type == 'email',
                        onTap: () => onTypeChanged('email'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeChip(
                        label: l10n.loginTypeMobile,
                        selected: type == 'mobile',
                        onTap: () => onTypeChanged('mobile'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // ── Identifier Field ─────────────────────────
                TextFormField(
                  controller: identifierCtrl,
                  keyboardType: type == 'mobile'
                      ? TextInputType.number
                      : TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => onSubmit(),
                  inputFormatters: type == 'mobile'
                      ? [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ]
                      : null,
                  decoration: InputDecoration(
                    labelText: type == 'mobile'
                        ? l10n.loginLabelMobileNumber
                        : l10n.loginLabelEmail,
                    hintText: type == 'mobile'
                        ? l10n.loginHintMobileNumber
                        : l10n.loginHintEmail,
                    prefixIcon: Icon(
                      type == 'mobile'
                          ? Icons.phone_outlined
                          : Icons.email_outlined,
                    ),
                  ),
                  validator: (v) {
                    final val = v?.trim() ?? '';
                    if (val.isEmpty) {
                      return type == 'mobile'
                          ? l10n.loginValidationMobileRequired
                          : l10n.loginValidationEmailRequired;
                    }
                    if (type == 'mobile') {
                      if (val.length != 10) {
                        return l10n.loginValidationMobileLength;
                      }
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(val)) {
                        return l10n.loginValidationMobileInvalid;
                      }
                    } else {
                      if (!RegExp(
                        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(val)) {
                        return l10n.loginValidationEmailInvalid;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // ── Send OTP Button ──────────────────────────
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading ? null : onSubmit,
                    child: state is AuthLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.loginSendOtpButton),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.blue
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.blue
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
