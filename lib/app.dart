import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

/// Shown only at startup. Listens to the root [AuthBloc] and redirects once
/// the token check completes — to dashboard if valid, to login otherwise.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed(RouteNames.login);
        }
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
