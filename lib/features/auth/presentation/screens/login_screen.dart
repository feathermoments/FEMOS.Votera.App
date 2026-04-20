import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/l10n/app_localizations.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/widgets/powered_by_footer.dart';
import 'package:votera_app/features/auth/presentation/block/auth_bloc.dart';
import 'package:votera_app/features/auth/presentation/block/auth_event.dart';
import 'package:votera_app/features/auth/presentation/block/auth_state.dart';

// ── Country code model + list ─────────────────────────────────────────────────
class _CountryCode {
  const _CountryCode({
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.minDigits,
    required this.maxDigits,
  });

  final String name;
  final String dialCode;
  final String flag;
  final int minDigits;
  final int maxDigits;
}

const List<_CountryCode> _kCountryCodes = [
  _CountryCode(
    name: 'India',
    dialCode: '+91',
    flag: '🇮🇳',
    minDigits: 10,
    maxDigits: 10,
  ),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _identifierFocus = FocusNode();
  String _type = 'email';
  _CountryCode _selectedCountry = _kCountryCodes.first;
  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Optional post-auth redirect injected via route arguments.
  String? _nextRoute;
  Object? _nextArgs;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
  }

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
    _identifierFocus.dispose();
    _entryCtrl.dispose();
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
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ctx.isWide
                      ? _WideLayout(
                          formKey: _formKey,
                          identifierCtrl: _identifierCtrl,
                          identifierFocus: _identifierFocus,
                          type: _type,
                          state: state,
                          ctx: ctx,
                          selectedCountry: _selectedCountry,
                          onTypeChanged: (t) {
                            setState(() {
                              _type = t;
                              _selectedCountry = _kCountryCodes.first;
                            });
                            _identifierCtrl.clear();
                            _formKey.currentState?.reset();
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _identifierFocus.requestFocus(),
                            );
                          },
                          onShowCountryPicker: _showCountryPicker,
                          onSubmit: () => _submit(ctx, state),
                        )
                      : _FormBody(
                          formKey: _formKey,
                          identifierCtrl: _identifierCtrl,
                          identifierFocus: _identifierFocus,
                          type: _type,
                          state: state,
                          ctx: ctx,
                          selectedCountry: _selectedCountry,
                          onTypeChanged: (t) {
                            setState(() {
                              _type = t;
                              _selectedCountry = _kCountryCodes.first;
                            });
                            _identifierCtrl.clear();
                            _formKey.currentState?.reset();
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _identifierFocus.requestFocus(),
                            );
                          },
                          onShowCountryPicker: _showCountryPicker,
                          onSubmit: () => _submit(ctx, state),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.metallicBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Country Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final country in _kCountryCodes)
                RadioListTile<_CountryCode>(
                  value: country,
                  groupValue: _selectedCountry,
                  activeColor: AppColors.blue,
                  title: Text('${country.flag}  ${country.name}'),
                  secondary: Text(
                    country.dialCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onChanged: (selected) {
                    if (selected != null) {
                      setState(() {
                        _selectedCountry = selected;
                        _identifierCtrl.clear();
                      });
                    }
                    Navigator.pop(sheetCtx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _submit(BuildContext ctx, AuthState state) {
    if (state is AuthLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      ctx.read<AuthBloc>().add(
        SendOtpRequested(
          identifier: _identifierCtrl.text.trim(),
          type: _type,
          countryCode: _type == 'mobile' ? _selectedCountry.dialCode : null,
        ),
      );
    }
  }
}

// ── Wide (tablet / desktop) layout ────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.formKey,
    required this.identifierCtrl,
    required this.identifierFocus,
    required this.type,
    required this.state,
    required this.ctx,
    required this.selectedCountry,
    required this.onTypeChanged,
    required this.onShowCountryPicker,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierCtrl;
  final FocusNode identifierFocus;
  final String type;
  final AuthState state;
  final BuildContext ctx;
  final _CountryCode selectedCountry;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onShowCountryPicker;
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
                        Image.asset(
                          'assets/images/app_icon.png',
                          width: 120,
                          fit: BoxFit.contain,
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
                  identifierFocus: identifierFocus,
                  type: type,
                  state: state,
                  ctx: ctx,
                  selectedCountry: selectedCountry,
                  onTypeChanged: onTypeChanged,
                  onShowCountryPicker: onShowCountryPicker,
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
    required this.identifierFocus,
    required this.type,
    required this.state,
    required this.ctx,
    required this.selectedCountry,
    required this.onTypeChanged,
    required this.onShowCountryPicker,
    required this.onSubmit,
    this.hideBranding = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierCtrl;
  final FocusNode identifierFocus;
  final String type;
  final AuthState state;
  final BuildContext ctx;
  final _CountryCode selectedCountry;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onShowCountryPicker;
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 110,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                const SizedBox(height: 32),
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
                const SizedBox(height: 16),
                // ── Identifier Field ─────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: TextFormField(
                    key: ValueKey(type),
                    controller: identifierCtrl,
                    focusNode: identifierFocus,
                    keyboardType: type == 'mobile'
                        ? TextInputType.number
                        : TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => onSubmit(),
                    inputFormatters: type == 'mobile'
                        ? [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              selectedCountry.maxDigits,
                            ),
                          ]
                        : null,
                    decoration: InputDecoration(
                      labelText: type == 'mobile'
                          ? l10n.loginLabelMobileNumber
                          : l10n.loginLabelEmail,
                      hintText: type == 'mobile'
                          ? l10n.loginHintMobileNumber
                          : l10n.loginHintEmail,
                      prefix: type == 'mobile'
                          ? GestureDetector(
                              onTap: onShowCountryPicker,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${selectedCountry.flag}  ${selectedCountry.dialCode}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 1,
                                    height: 18,
                                    color: AppColors.metallicBorder,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            )
                          : null,
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
                        if (val.length < selectedCountry.minDigits ||
                            val.length > selectedCountry.maxDigits) {
                          return l10n.loginValidationMobileLength;
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
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
                ),
                const SizedBox(height: 20),
                // ── Send OTP Button ───────────────────────
                SizedBox(
                  height: 48,
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
                const SizedBox(height: 32),
                // ── Powered by ───────────────────────────────
                const PoweredByFooter(),
                const SizedBox(height: 16),
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
