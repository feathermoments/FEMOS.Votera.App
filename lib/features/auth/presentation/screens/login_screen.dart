import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String _type = 'mobile';

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
              arguments: {'identifier': state.identifier, 'type': state.type},
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 48),
                        // ── App Icon ──────────────────────────────────
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
                          'Votera',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Every Voice Matters',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 44),
                        // ── Contact Type Selector ─────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _TypeChip(
                                label: 'Mobile',
                                selected: _type == 'mobile',
                                onTap: () => setState(() => _type = 'mobile'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TypeChip(
                                label: 'Email',
                                selected: _type == 'email',
                                onTap: () => setState(() => _type = 'email'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // ── Identifier Field ─────────────────────────
                        TextFormField(
                          controller: _identifierCtrl,
                          keyboardType: _type == 'mobile'
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(ctx, state),
                          decoration: InputDecoration(
                            labelText: _type == 'mobile'
                                ? 'Mobile Number'
                                : 'Email',
                            hintText: _type == 'mobile'
                                ? '9876543210'
                                : 'you@example.com',
                            prefixIcon: Icon(
                              _type == 'mobile'
                                  ? Icons.phone_outlined
                                  : Icons.email_outlined,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return _type == 'mobile'
                                  ? 'Mobile number is required'
                                  : 'Email is required';
                            }
                            if (_type == 'email' && !v.contains('@')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // ── Send OTP Button ──────────────────────────
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () => _submit(ctx, state),
                            child: state is AuthLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Send OTP'),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
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
