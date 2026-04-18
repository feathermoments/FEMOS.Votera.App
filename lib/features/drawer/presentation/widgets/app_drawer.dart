import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/l10n/app_localizations.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/features/auth/presentation/block/auth_bloc.dart';
import 'package:votera_app/features/auth/presentation/block/auth_event.dart';
import 'package:votera_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:votera_app/features/user/presentation/cubit/user_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.currentTab,
    required this.onTabSelected,
    super.key,
  });

  final int currentTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 305,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // â”€â”€ Profile Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                final String name;
                final String identifier;
                if (state is UserProfileLoaded) {
                  name = state.profile.name;
                  identifier = state.profile.email.isNotEmpty
                      ? state.profile.email
                      : state.profile.mobile;
                } else {
                  name = '';
                  identifier = '';
                }
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'V';
                return Container(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.blue.withAlpha(12),
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.blueGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (name.isNotEmpty)
                              Text(
                                name,
                                style: AppTypography.sectionHeading.copyWith(
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (identifier.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                identifier,
                                style: AppTypography.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // â”€â”€ Menu Sections â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: AppLocalizations.of(context).drawerSectionPolls,
                      items: [
                        _MenuItem(
                          icon: Icons.how_to_vote_rounded,
                          label: AppLocalizations.of(
                            context,
                          ).drawerMenuDashboard,
                          color: AppColors.blue,
                          tabIndex: 0,
                        ),
                        _MenuItem(
                          icon: Icons.bar_chart_rounded,
                          label: AppLocalizations.of(context).drawerMenuMyPolls,
                          color: const Color(0xFF6366F1),
                          route: RouteNames.polls,
                        ),
                      ],
                      currentTab: currentTab,
                      onTap: (i) {
                        Navigator.of(context).pop();
                        onTabSelected(i);
                      },
                      onRoute: (route) {
                        final state = context.read<UserCubit>().state;
                        final userId = state is UserProfileLoaded
                            ? state.profile.userId
                            : 0;
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, route, arguments: userId);
                      },
                    ),
                    _Section(
                      title: AppLocalizations.of(
                        context,
                      ).drawerSectionWorkspaces,
                      items: [
                        _MenuItem(
                          icon: Icons.workspaces_rounded,
                          label: AppLocalizations.of(
                            context,
                          ).drawerMenuMyWorkspaces,
                          color: const Color(0xFF0EA5E9),
                          route: RouteNames.workspaces,
                        ),
                        _MenuItem(
                          icon: Icons.mark_email_unread_outlined,
                          label: AppLocalizations.of(context).drawerMenuInbox,
                          color: const Color(0xFFF59E0B),
                          route: RouteNames.workspaceInbox,
                        ),
                      ],
                      currentTab: currentTab,
                      onTap: (_) {},
                      onRoute: (route) {
                        final state = context.read<UserCubit>().state;
                        final userId = state is UserProfileLoaded
                            ? state.profile.userId
                            : 0;
                        Navigator.of(context).pop();
                        if (route == RouteNames.workspaceInbox) {
                          Navigator.pushNamed(
                            context,
                            route,
                            arguments: userId,
                          );
                        } else {
                          Navigator.pushNamed(context, route);
                        }
                      },
                    ),
                    _Section(
                      title: AppLocalizations.of(context).drawerSectionAccount,
                      items: [
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          label: AppLocalizations.of(
                            context,
                          ).drawerMenuNotifications,
                          color: const Color(0xFFEF4444),
                          route: RouteNames.notifications,
                        ),
                        _MenuItem(
                          icon: Icons.person_outline_rounded,
                          label: AppLocalizations.of(context).drawerMenuProfile,
                          color: const Color(0xFF10B981),
                          route: RouteNames.profile,
                        ),
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          label: AppLocalizations.of(
                            context,
                          ).drawerMenuSettings,
                          color: AppColors.textSecondary,
                          route: RouteNames.settings,
                        ),
                      ],
                      currentTab: currentTab,
                      onTap: (i) {
                        Navigator.of(context).pop();
                        onTabSelected(i);
                      },
                      onRoute: (route) {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, route);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // â”€â”€ Logout â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<AuthBloc>().add(const LogoutRequested());
                    Navigator.pushReplacementNamed(context, RouteNames.login);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          AppLocalizations.of(context).drawerLogOut,
                          style: AppTypography.cardTitle.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.items,
    required this.currentTab,
    required this.onTap,
    this.onRoute,
  });

  final String title;
  final List<_MenuItem> items;
  final int currentTab;
  final ValueChanged<int> onTap;
  final ValueChanged<String>? onRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
          child: Text(
            title,
            style: AppTypography.label.copyWith(letterSpacing: 1.4),
          ),
        ),
        ...items.map((item) {
          final isActive = item.tabIndex != null && item.tabIndex == currentTab;
          return Material(
            color: isActive ? AppColors.blue.withAlpha(10) : Colors.transparent,
            child: InkWell(
              onTap: () {
                if (item.route != null && onRoute != null) {
                  onRoute!(item.route!);
                } else {
                  onTap(item.tabIndex ?? -1);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: item.color.withAlpha(isActive ? 25 : 15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, color: item.color, size: 16),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTypography.cardTitle.copyWith(
                          color: isActive
                              ? AppColors.blue
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    this.tabIndex,
    this.route,
  });

  final IconData icon;
  final String label;
  final Color color;
  final int? tabIndex;
  final String? route;
}
