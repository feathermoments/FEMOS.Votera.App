import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/features/auth/presentation/block/auth_bloc.dart';
import 'package:votera_app/features/auth/presentation/screens/login_screen.dart';
import 'package:votera_app/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:votera_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:votera_app/features/poll/presentation/screens/polls_list_screen.dart';
import 'package:votera_app/features/poll/presentation/screens/add_poll_screen.dart';
import 'package:votera_app/features/poll/presentation/screens/poll_detail_screen.dart';
import 'package:votera_app/features/workspace/presentation/screens/add_workspace_screen.dart';
import 'package:votera_app/features/workspace/presentation/screens/invite_member_screen.dart';
import 'package:votera_app/features/workspace/presentation/screens/join_workspace_screen.dart';
import 'package:votera_app/features/workspace/presentation/screens/workspace_detail_screen.dart';
import 'package:votera_app/features/workspace/presentation/screens/workspace_inbox_screen.dart';
import 'package:votera_app/features/workspace/presentation/screens/workspace_invite_links_screen.dart';
import 'package:votera_app/features/workspace/presentation/screens/workspace_list_screen.dart';
import 'package:votera_app/features/notification/presentation/screens/notifications_screen.dart';
import 'package:votera_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:votera_app/features/user/presentation/screens/profile_screen.dart';
import 'package:votera_app/features/workspace/presentation/screens/workspace_verification_screen.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case RouteNames.verifyOtp:
        return MaterialPageRoute(
          // VerifyOtpScreen reuses the AuthBloc from the widget tree;
          // wrap in a fresh BlocProvider so it remains self-contained.
          builder: (_) => BlocProvider(
            create: (_) => AuthBloc(),
            child: const VerifyOtpScreen(),
          ),
          settings: settings,
        );
      case RouteNames.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case RouteNames.workspaces:
        return MaterialPageRoute(
          builder: (_) => const WorkspaceListScreen(),
          settings: settings,
        );
      case RouteNames.workspaceInbox:
        final userId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => WorkspaceInboxScreen(userId: userId),
          settings: settings,
        );
      case RouteNames.addWorkspace:
        return MaterialPageRoute(
          builder: (_) => const AddWorkspaceScreen(),
          settings: settings,
        );
      case RouteNames.joinWorkspace:
        return MaterialPageRoute(
          builder: (_) => const JoinWorkspaceScreen(),
          settings: settings,
        );
      case RouteNames.workspaceDetail:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => WorkspaceDetailScreen(workspaceId: id),
          settings: settings,
        );
      case RouteNames.inviteMember:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => InviteMemberScreen(workspaceId: id),
          settings: settings,
        );
      case RouteNames.workspaceVerification:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => WorkspaceVerificationScreen(workspaceId: id),
          settings: settings,
        );
      case RouteNames.workspaceInviteLinks:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => WorkspaceInviteLinksScreen(
            workspaceId: args['workspaceId'] as int,
            role: args['role'] as String,
          ),
          settings: settings,
        );
      case RouteNames.polls:
        final userId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => PollsListScreen(userId: userId),
          settings: settings,
        );
      case RouteNames.addPoll:
        return MaterialPageRoute(
          builder: (_) => const AddPollScreen(),
          settings: settings,
        );
      case RouteNames.pollDetail:
        final args = settings.arguments as Map<String, int>;
        return MaterialPageRoute(
          builder: (_) => PollDetailScreen(
            pollId: args['pollId']!,
            userId: args['userId']!,
          ),
          settings: settings,
        );
      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      case RouteNames.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );
      case RouteNames.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
    }
  }
}
