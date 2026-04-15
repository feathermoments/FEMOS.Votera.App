import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:votera_app/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/features/drawer/presentation/widgets/app_drawer.dart';
import 'package:votera_app/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:votera_app/features/notification/presentation/cubit/notification_state.dart';
import 'package:votera_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:votera_app/features/user/presentation/cubit/user_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DashboardCubit()..load()),
        BlocProvider(create: (_) => UserCubit()..loadProfile()),
        BlocProvider(create: (_) => NotificationCubit()..load()),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;

    // On wide screens, show a permanent NavigationRail sidebar instead of a drawer
    if (isWide) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          automaticallyImplyLeading: false,
          actions: [_NotificationButton()],
        ),
        body: Row(
          children: [
            // ── Navigation Rail ──────────────────────────────────
            NavigationRail(
              selectedIndex: _currentTab,
              onDestinationSelected: (i) {
                if (i == 0) {
                  setState(() => _currentTab = 0);
                } else if (i == 1) {
                  final userState = context.read<UserCubit>().state;
                  final userId = userState is UserProfileLoaded
                      ? userState.profile.userId
                      : 0;
                  Navigator.pushNamed(
                    context,
                    RouteNames.polls,
                    arguments: userId,
                  );
                } else if (i == 2) {
                  Navigator.pushNamed(context, RouteNames.workspaces);
                } else if (i == 3) {
                  Navigator.pushNamed(context, RouteNames.profile);
                } else if (i == 4) {
                  Navigator.pushNamed(context, RouteNames.settings);
                }
              },
              extended: context.isDesktop,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.blueGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.how_to_vote_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: Text('My Polls'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.workspaces_outlined),
                  selectedIcon: Icon(Icons.workspaces_rounded),
                  label: Text('Workspaces'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // ── Main content ─────────────────────────────────────
            Expanded(child: _DashboardContent()),
          ],
        ),
      );
    }

    // Mobile: original drawer layout
    return Scaffold(
      drawer: AppDrawer(
        currentTab: _currentTab,
        onTabSelected: (i) => setState(() => _currentTab = i),
      ),
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [_NotificationButton()],
      ),
      body: _DashboardContent(),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final unread = state is NotificationLoaded ? state.unreadCount : 0;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.pushNamed(
                context,
                RouteNames.notifications,
              ).then((_) => context.read<NotificationCubit>().load()),
            ),
            if (unread > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 17,
                    minHeight: 17,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DashboardError) {
          return Center(child: Text(state.message));
        }
        final polls = (state as DashboardLoaded).activePolls;
        final stats = state.stats;
        return RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().load(),
          color: AppColors.blue,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kWideMaxWidth),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Welcome Card ─────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blue.withAlpha(60),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.how_to_vote_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Votera Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // ── Stats Row ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.poll_outlined,
                            label: 'Active Polls',
                            value: '${stats.activePolls}',
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle_outline_rounded,
                            label: 'Votes Cast',
                            value: '${stats.votesCast}',
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people_outline_rounded,
                            label: 'Voters',
                            value: '${stats.voters}',
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Active Polls',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ── Poll List ─────────────────────────────────
                    if (polls.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'No active polls right now.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    else
                      ...polls.map(
                        (p) => _PollCard(
                          pollId: p.pollId,
                          question: p.question,
                          votes: p.totalVotes,
                          daysLeft: p.daysLeft,
                          isVoted: p.isVoted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  const _PollCard({
    required this.pollId,
    required this.question,
    required this.votes,
    required this.daysLeft,
    required this.isVoted,
  });

  final int pollId;
  final String question;
  final int votes;
  final int daysLeft;
  final bool isVoted;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserCubit>().currentProfile?.userId ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(
          context,
          RouteNames.pollDetail,
          arguments: {'pollId': pollId, 'userId': userId},
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blue.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.poll_outlined, color: AppColors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '$votes votes · $daysLeft day${daysLeft == 1 ? '' : 's'} left',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isVoted
                                ? AppColors.success.withAlpha(20)
                                : AppColors.warning.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVoted
                                    ? Icons.check_circle_rounded
                                    : Icons.how_to_vote_outlined,
                                size: 11,
                                color: isVoted
                                    ? AppColors.successDark
                                    : AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isVoted ? 'Voted' : 'Not Voted',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isVoted
                                      ? AppColors.successDark
                                      : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
