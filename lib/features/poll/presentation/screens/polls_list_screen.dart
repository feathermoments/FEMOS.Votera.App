import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/l10n/app_localizations.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/core/widgets/gradient_app_bar.dart';
import 'package:votera_app/features/poll/domain/entities/poll_entity.dart';
import 'package:votera_app/features/poll/presentation/cubit/poll_cubit.dart';
import 'package:votera_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:votera_app/features/user/presentation/cubit/user_state.dart';

class PollsListScreen extends StatelessWidget {
  const PollsListScreen({super.key, required this.userId});
  final int userId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PollCubit()..loadPolls(userId)),
        BlocProvider(create: (_) => UserCubit()..loadProfile()),
      ],
      child: _PollsListView(userId: userId),
    );
  }
}

class _PollsListView extends StatefulWidget {
  const _PollsListView({required this.userId});
  final int userId;

  @override
  State<_PollsListView> createState() => _PollsListViewState();
}

class _PollsListViewState extends State<_PollsListView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  bool _isPollActive(PollSummaryEntity poll) {
    if (poll.expiryDate.isEmpty) return true;
    try {
      return DateTime.parse(poll.expiryDate).isAfter(DateTime.now());
    } catch (_) {
      return true;
    }
  }

  void _goAdd(BuildContext context) async {
    final result = await Navigator.pushNamed(context, RouteNames.addPoll);
    if (result == true && context.mounted) {
      context.read<PollCubit>().loadPolls(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user has workspaces (for FAB visibility)
    final userState = context.watch<UserCubit>().state;
    final hasWorkspace =
        userState is UserProfileLoaded &&
        userState.profile.workspaces.isNotEmpty;

    return Scaffold(
      appBar: GradientAppBar(
        title: AppLocalizations.of(context).pollsListTitle,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Closed'),
          ],
        ),
      ),
      floatingActionButton: hasWorkspace
          ? FloatingActionButton(
              onPressed: () => _goAdd(context),
              backgroundColor: AppColors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: BlocConsumer<PollCubit, PollState>(
        listener: (context, state) {
          if (state is PollError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PollLoading || state is PollInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final polls = state is PollListLoaded
              ? state.polls
              : <PollSummaryEntity>[];
          final active = polls.where(_isPollActive).toList();
          final closed = polls.where((p) => !_isPollActive(p)).toList();

          return Column(
            children: [
              // ── Quick stats bar ────────────────────────────
              _StatsBar(
                total: polls.length,
                active: active.length,
                closed: closed.length,
              ),
              // ── Tab views ──────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _PollTab(
                      polls: active,
                      userId: widget.userId,
                      emptyIcon: Icons.how_to_vote_outlined,
                      emptyMessage: 'No active polls',
                      onRefresh: () =>
                          context.read<PollCubit>().loadPolls(widget.userId),
                    ),
                    _PollTab(
                      polls: closed,
                      userId: widget.userId,
                      emptyIcon: Icons.lock_outline_rounded,
                      emptyMessage: 'No closed polls',
                      onRefresh: () =>
                          context.read<PollCubit>().loadPolls(widget.userId),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Stats Bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.total,
    required this.active,
    required this.closed,
  });
  final int total;
  final int active;
  final int closed;

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: AppColors.whiteCard,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _StatChip(label: 'Total', value: total, color: AppColors.blue),
          const SizedBox(width: 10),
          _StatChip(label: 'Active', value: active, color: AppColors.success),
          const SizedBox(width: 10),
          _StatChip(label: 'Closed', value: closed, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Poll Tab ──────────────────────────────────────────────────────────────────

class _PollTab extends StatelessWidget {
  const _PollTab({
    required this.polls,
    required this.userId,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.onRefresh,
  });
  final List<PollSummaryEntity> polls;
  final int userId;
  final IconData emptyIcon;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (polls.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.blue.withAlpha(12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                emptyIcon,
                size: 34,
                color: AppColors.blue.withAlpha(100),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: AppTypography.sectionHeading.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // On wide screens use a two-column grid; on mobile use a list
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: context.isWide
          ? GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 88),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.isDesktop ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: polls.length,
              itemBuilder: (context, i) =>
                  _PollCard(poll: polls[i], userId: userId),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 88),
              itemCount: polls.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) =>
                  _PollCard(poll: polls[i], userId: userId),
            ),
    );
  }
}

// ── Poll Card ─────────────────────────────────────────────────────────────────

class _PollCard extends StatelessWidget {
  const _PollCard({required this.poll, required this.userId});
  final PollSummaryEntity poll;
  final int userId;

  @override
  Widget build(BuildContext context) {
    final isActive =
        poll.expiryDate.isEmpty ||
        DateTime.tryParse(poll.expiryDate)?.isAfter(DateTime.now()) == true;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.metallicBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            Navigator.pushNamed(
              context,
              RouteNames.pollDetail,
              arguments: {'pollId': poll.pollId, 'userId': userId},
            ).then((voted) {
              if (voted == true && context.mounted) {
                context.read<PollCubit>().loadPolls(userId);
              }
            }),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question + status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withAlpha(12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.poll_outlined,
                      color: AppColors.blue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      poll.question,
                      style: AppTypography.cardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(isActive: isActive),
                ],
              ),
              const SizedBox(height: 10),
              // Meta row
              Row(
                children: [
                  const Icon(
                    Icons.workspaces_outlined,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      poll.workspaceName.isNotEmpty
                          ? poll.workspaceName
                          : 'No workspace',
                      style: AppTypography.captionSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.label_outline_rounded,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(poll.category, style: AppTypography.captionSmall),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _capitalize(poll.visibility),
                    style: AppTypography.captionSmall,
                  ),
                  const Spacer(),
                  if (poll.expiryDate.isNotEmpty) ...[
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(poll.expiryDate),
                      style: AppTypography.captionSmall,
                    ),
                  ],
                  if (poll.hasVoted) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.how_to_vote_rounded,
                      size: 13,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Voted',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.textMuted;
    final label = isActive ? 'Active' : 'Closed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
