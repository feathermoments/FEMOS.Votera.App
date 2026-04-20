import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/features/auth/presentation/block/auth_bloc.dart';
import 'package:votera_app/features/auth/presentation/block/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  String _quote = '';
  bool _navigated = false;

  // ── Two-gate navigation state (both must resolve before navigating) ──
  String? _pendingInviteCode;
  bool _linkCheckDone = false;
  bool _timerDone = false;
  bool _authCheckDone = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _loadRandomQuote();
    _checkInitialLink();

    // Minimum splash display time.
    Timer(const Duration(seconds: 3), () {
      _timerDone = true;
      _tryNavigate();
    });
  }

  Future<void> _loadRandomQuote() async {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final langCode = locale.languageCode;
      // Try device locale; fall back to English.
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/l10n/$langCode.json');
      } catch (_) {
        jsonString = await rootBundle.loadString('assets/l10n/en.json');
      }
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final quotes = (jsonMap['splashQuotes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList();
      if (quotes != null && quotes.isNotEmpty) {
        final pick = quotes[Random().nextInt(quotes.length)];
        if (mounted) setState(() => _quote = pick);
      }
    } catch (_) {}
  }

  Future<void> _checkInitialLink() async {
    try {
      // Web: Uri.base is synchronous and available immediately.
      final webCode = _extractInviteCode(Uri.base);
      if (webCode != null) {
        _pendingInviteCode = webCode;
        _linkCheckDone = true;
        _tryNavigate();
        return;
      }
      // Native cold-start: read the OS intent/URL.
      final uri = await AppLinks().getInitialLink();
      if (uri != null) _pendingInviteCode = _extractInviteCode(uri);
    } catch (_) {}
    _linkCheckDone = true;
    _tryNavigate();
  }

  String? _extractInviteCode(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length >= 3 &&
        segments[0] == 'workspace' &&
        segments[1] == 'join' &&
        segments[2].isNotEmpty) {
      return segments[2];
    }
    return null;
  }

  void _onAuthResolved({required bool authenticated}) {
    _authCheckDone = true;
    _isAuthenticated = authenticated;
    _tryNavigate();
  }

  /// Navigates only when the timer, the link check, AND auth have all resolved.
  void _tryNavigate() {
    if (!mounted || _navigated) return;
    if (!_timerDone || !_linkCheckDone || !_authCheckDone) return;
    _navigated = true;
    if (_pendingInviteCode != null) {
      Navigator.of(context).pushReplacementNamed(
        RouteNames.workspaceJoinInvite,
        arguments: _pendingInviteCode,
      );
    } else if (_isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
    } else {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _onAuthResolved(authenticated: true);
        } else if (state is AuthUnauthenticated) {
          _onAuthResolved(authenticated: false);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.blueGradient),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 3),

                    // ── Logo ──────────────────────────────────────
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── App name ──────────────────────────────────
                    const Text(
                      'Votera',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Tagline ───────────────────────────────────
                    const Text(
                      'Every Voice Matters',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ── Random quote ──────────────────────────────
                    if (_quote.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: AnimatedOpacity(
                          opacity: _quote.isEmpty ? 0 : 1,
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withAlpha(50),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '"$_quote"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                    const Spacer(flex: 2),

                    // ── Loading indicator ─────────────────────────
                    const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white54,
                          strokeWidth: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
