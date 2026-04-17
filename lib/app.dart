import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/core/router/app_router.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/storage/local_storage.dart';
import 'package:votera_app/core/theme/app_theme.dart';
import 'package:votera_app/core/theme/theme_cubit.dart';
import 'package:votera_app/features/auth/presentation/block/auth_bloc.dart';
import 'package:votera_app/features/auth/presentation/block/auth_event.dart';
import 'package:votera_app/features/auth/presentation/block/auth_state.dart';

class VoteraApp extends StatelessWidget {
  const VoteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(const AppStarted())),
        BlocProvider(create: (_) => ThemeCubit(sl<LocalStorageService>())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp(
          title: 'Votera',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

/// Startup screen that coordinates auth + deep-link checks before navigating.
///
/// Both checks run in parallel. Navigation happens only after BOTH resolve so
/// a pending invite link is never lost in the auth→dashboard race.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  // ── State tracked for the two async checks ──────────────────────────────
  String? _pendingInviteCode;
  bool _linkCheckDone = false;

  bool _authCheckDone = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    // ── 1. Web: Uri.base is synchronous — zero latency ───────────────────
    //    On native it returns a file:// URI that won't match, so it's safe.
    final webCode = _extractInviteCode(Uri.base);
    if (webCode != null) {
      _pendingInviteCode = webCode;
      _setLinkCheckDone();
    } else {
      // ── 2. Native cold-start: read from the OS intent/URL ────────────
      _checkNativeInitialLink();
    }

    // ── 3. Foreground links (app already running) ────────────────────────
    _linkSub = _appLinks.uriLinkStream.listen(_handleForegroundLink);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  // ── Link helpers ─────────────────────────────────────────────────────────

  Future<void> _checkNativeInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _pendingInviteCode = _extractInviteCode(uri);
    } catch (_) {}
    _setLinkCheckDone();
  }

  void _setLinkCheckDone() {
    _linkCheckDone = true;
    _tryNavigate();
  }

  /// Handles a URI arriving while the app is already in the foreground.
  void _handleForegroundLink(Uri uri) {
    final code = _extractInviteCode(uri);
    if (code == null || !mounted) return;
    Navigator.of(
      context,
    ).pushNamed(RouteNames.workspaceJoinInvite, arguments: code);
  }

  /// Extracts the invite code from:
  ///   http(s)://<host>/workspace/join/{code}
  ///   votera://workspace/join/{code}
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

  // ── Auth helper ──────────────────────────────────────────────────────────

  void _onAuthResolved({required bool authenticated}) {
    _authCheckDone = true;
    _isAuthenticated = authenticated;
    _tryNavigate();
  }

  // ── Navigation gate ──────────────────────────────────────────────────────

  /// Called whenever either check completes. Navigates only when BOTH are done.
  void _tryNavigate() {
    if (!mounted || !_linkCheckDone || !_authCheckDone) return;

    if (_pendingInviteCode != null) {
      // Let WorkspaceJoinInviteScreen handle its own auth check.
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
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated) {
          _onAuthResolved(authenticated: true);
        } else if (state is AuthUnauthenticated) {
          _onAuthResolved(authenticated: false);
        }
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
