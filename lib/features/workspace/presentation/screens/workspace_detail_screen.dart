import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_state.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  const WorkspaceDetailScreen({super.key, required this.workspaceId});
  final int workspaceId;

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final WorkspaceCubit _cubit;

  WorkspaceEntity? _workspace;
  List<WorkspaceMemberEntity> _allMembers = [];
  bool _membersLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _cubit = WorkspaceCubit()..loadWorkspace(widget.workspaceId);
    _tabs.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabs.indexIsChanging) return;
    if ((_tabs.index == 1 || _tabs.index == 2) && !_membersLoaded) {
      _cubit.loadMembers(widget.workspaceId);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<WorkspaceCubit, WorkspaceState>(
        listener: (context, state) {
          if (state is WorkspaceDetailLoaded) {
            setState(() => _workspace = state.workspace);
          } else if (state is WorkspaceMembersLoaded) {
            setState(() {
              _allMembers = state.members;
              _membersLoaded = true;
            });
          } else if (state is WorkspaceActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Refresh after action
            _cubit.loadMembers(widget.workspaceId);
          } else if (state is WorkspaceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is WorkspaceLoading && _workspace == null;
          return Scaffold(
            appBar: AppBar(
              title: Text(_workspace?.name ?? 'Workspace'),
              actions: [
                if (_workspace != null && _workspace!.role == 'Admin')
                  IconButton(
                    icon: const Icon(Icons.link_rounded),
                    tooltip: 'Invite Links',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.workspaceInviteLinks,
                      arguments: {
                        'workspaceId': widget.workspaceId,
                        'role': _workspace!.role,
                      },
                    ),
                  ),
                if (_workspace != null && _workspace!.role == 'Admin')
                  IconButton(
                    icon: const Icon(Icons.verified_user_outlined),
                    tooltip: 'Verification',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.workspaceVerification,
                      arguments: widget.workspaceId,
                    ),
                  ),
              ],
              bottom: TabBar(
                controller: _tabs,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Members'),
                  Tab(text: 'Requests'),
                ],
              ),
            ),
            floatingActionButton:
                _workspace != null && _workspace!.role == 'Admin'
                ? FloatingActionButton.extended(
                    onPressed: () =>
                        Navigator.pushNamed(
                          context,
                          RouteNames.inviteMember,
                          arguments: widget.workspaceId,
                        ).then((_) {
                          _membersLoaded = false;
                          _cubit.loadMembers(widget.workspaceId);
                        }),
                    backgroundColor: AppColors.blue,
                    icon: const Icon(
                      Icons.person_add_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Invite',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : null,
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _OverviewTab(workspace: _workspace),
                      _MembersTab(
                        workspaceId: widget.workspaceId,
                        members: _allMembers
                            .where((m) => m.status != 'Pending')
                            .toList(),
                        isLoading:
                            state is WorkspaceLoading &&
                            _membersLoaded == false,
                        isAdmin: _workspace?.role == 'Admin',
                      ),
                      _RequestsTab(
                        requests: _allMembers
                            .where((m) => m.status == 'Pending')
                            .toList(),
                        isLoading:
                            state is WorkspaceLoading &&
                            _membersLoaded == false,
                        isAdmin: _workspace?.role == 'Admin',
                        onApprove: (userId) => _cubit.approveMember(
                          workspaceId: widget.workspaceId,
                          memberUserId: userId,
                          isApproved: true,
                        ),
                        onReject: (userId) => _cubit.approveMember(
                          workspaceId: widget.workspaceId,
                          memberUserId: userId,
                          isApproved: false,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.workspace});
  final WorkspaceEntity? workspace;

  @override
  Widget build(BuildContext context) {
    final ws = workspace;
    if (ws == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kWideMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          ws.name.isNotEmpty ? ws.name[0].toUpperCase() : 'W',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ws.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (ws.isVerified)
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ws.slug,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Stats ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.people_outline_rounded,
                      label: 'Members',
                      value: '${ws.memberCount}',
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.poll_outlined,
                      label: 'Polls',
                      value: '${ws.pollCount}',
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Details ───────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.category_outlined,
                        label: 'Type',
                        value: ws.workspaceType,
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        icon: ws.isPublic
                            ? Icons.public_rounded
                            : Icons.lock_outline_rounded,
                        label: 'Visibility',
                        value: ws.isPublic ? 'Public' : 'Private',
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        icon: Icons.badge_outlined,
                        label: 'Your Role',
                        value: ws.role,
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        icon: Icons.verified_user_outlined,
                        label: 'Verified',
                        value: ws.isVerified ? 'Yes' : 'No',
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Joined',
                        value: ws.joinedOn,
                      ),
                      const Divider(height: 20),
                      _DetailRow(
                        icon: Icons.access_time_rounded,
                        label: 'Created',
                        value: ws.createdOn,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(label, style: AppTypography.captionSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.bodySmall),
        const Spacer(),
        Text(
          value,
          style: AppTypography.cardTitle.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Members Tab ───────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  const _MembersTab({
    required this.workspaceId,
    required this.members,
    required this.isLoading,
    required this.isAdmin,
  });
  final int workspaceId;
  final List<WorkspaceMemberEntity> members;
  final bool isLoading;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (members.isEmpty) {
      return _EmptyTabState(
        icon: Icons.people_outline,
        message: 'No active members yet',
      );
    }
    // compute status counts
    final total = members.length;
    final approved = members.where((m) => m.status == 'Approved').length;
    final rejected = members.where((m) => m.isRejected).length;
    final declined = members.where((m) => m.isDeclined).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              _CountChip(label: 'Total', count: total, color: AppColors.blue),
              const SizedBox(width: 8),
              _CountChip(
                label: 'Approved',
                count: approved,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _CountChip(
                label: 'Rejected',
                count: rejected,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              _CountChip(
                label: 'Declined',
                count: declined,
                color: AppColors.warning,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _MemberTile(
              workspaceId: workspaceId,
              member: members[i],
              isAdmin: isAdmin,
            ),
          ),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Text('$count', style: AppTypography.cardTitle.copyWith(color: color)),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.captionSmall),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.workspaceId,
    required this.member,
    required this.isAdmin,
  });
  final int workspaceId;
  final WorkspaceMemberEntity member;
  final bool isAdmin;

  Color get _roleColor {
    switch (member.role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'owner':
        return AppColors.gold;
      default:
        return AppColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';
    final statusColor = member.isRejected
        ? AppColors.error
        : member.isDeclined
        ? AppColors.warning
        : AppColors.success;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.blue.withAlpha(20),
              child: Text(
                initial,
                style: AppTypography.cardTitle.copyWith(color: AppColors.blue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: AppTypography.cardTitle),
                  const SizedBox(height: 2),
                  Text(
                    member.email.isNotEmpty
                        ? member.email
                        : member.mobileNumber,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            // ── badges + menu in one row ──────────────────
            if (member.status != 'Approved') ...[
              _RoleBadge(label: member.status, color: statusColor),
              const SizedBox(width: 6),
            ],
            _RoleBadge(label: member.role, color: _roleColor),
            const SizedBox(width: 4),
            if (isAdmin)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                padding: EdgeInsets.zero,
                onSelected: (value) async {
                  if (value == 'remove') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remove member'),
                        content: Text(
                          'Remove ${member.name} from the workspace?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Remove',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        await context.read<WorkspaceCubit>().removeMember(
                          workspaceId: workspaceId,
                          userId: member.userId,
                        );
                        context.read<WorkspaceCubit>().loadMembers(workspaceId);
                      } catch (_) {}
                    }
                  } else if (value == 'report') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reported ${member.name}'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_remove_rounded,
                          size: 18,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text('Remove'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          size: 18,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text('Report'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Requests Tab ──────────────────────────────────────────────────────────────

class _RequestsTab extends StatelessWidget {
  const _RequestsTab({
    required this.requests,
    required this.isLoading,
    required this.isAdmin,
    required this.onApprove,
    required this.onReject,
  });
  final List<WorkspaceMemberEntity> requests;
  final bool isLoading;
  final bool isAdmin;
  final ValueChanged<int> onApprove;
  final ValueChanged<int> onReject;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (requests.isEmpty) {
      return _EmptyTabState(
        icon: Icons.inbox_outlined,
        message: 'No pending requests',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _RequestTile(
        member: requests[i],
        isAdmin: isAdmin,
        onApprove: () => onApprove(requests[i].userId),
        onReject: () => onReject(requests[i].userId),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.member,
    required this.isAdmin,
    required this.onApprove,
    required this.onReject,
  });
  final WorkspaceMemberEntity member;
  final bool isAdmin;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final initial = member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.warning.withAlpha(20),
              child: Text(
                initial,
                style: AppTypography.cardTitle.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: AppTypography.cardTitle),
                  const SizedBox(height: 2),
                  Text(
                    member.email.isNotEmpty
                        ? member.email
                        : member.mobileNumber,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Requested to join',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionBtn(
                    icon: Icons.check_rounded,
                    color: AppColors.success,
                    onTap: onApprove,
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Icons.close_rounded,
                    color: AppColors.error,
                    onTap: onReject,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: AppColors.textFaint),
          const SizedBox(height: 12),
          Text(message, style: AppTypography.caption),
        ],
      ),
    );
  }
}
