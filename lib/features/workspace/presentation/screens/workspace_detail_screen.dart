import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/l10n/app_localizations.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/core/widgets/gradient_app_bar.dart';
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

  Future<void> _confirmExit(BuildContext context) async {
    final cubit = _cubit;
    final l10n = AppLocalizations.of(context);
    final workspaceName = _workspace?.name ?? 'this workspace';
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Warning header ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(color: AppColors.error.withAlpha(12)),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.error.withAlpha(60),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.workspaceLeaveDialogTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            // ── Body ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: l10n.workspaceLeaveDialogBody),
                        TextSpan(
                          text: '"$workspaceName"',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(text: l10n.workspaceLeaveDialogBodySuffix),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.warning.withAlpha(60),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.workspaceLeaveDialogWarning,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Actions ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(
                          color: AppColors.metallicBorder,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.workspaceLeaveCancel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.workspaceLeaveConfirm,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      cubit.exitWorkspace(workspaceId: widget.workspaceId);
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
          } else if (state is WorkspaceExitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You have left the workspace'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
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
            appBar: GradientAppBar(
              titleWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _workspace?.name ?? 'Workspace',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_workspace != null)
                    Text(
                      _workspace!.role,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              actions: [
                if (_workspace != null && _workspace!.role == 'Admin') ...[
                  IconButton(
                    icon: const Icon(Icons.link_rounded, color: Colors.white),
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
                  IconButton(
                    icon: const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.white,
                    ),
                    tooltip: 'Verification',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.workspaceVerification,
                      arguments: widget.workspaceId,
                    ),
                  ),
                ],
              ],
              bottom: TabBar(
                controller: _tabs,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
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
                    elevation: 4,
                    icon: const Icon(
                      Icons.person_add_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Invite Member',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _OverviewTab(
                        workspace: _workspace,
                        onLeave: _workspace?.role != 'Admin'
                            ? () => _confirmExit(context)
                            : null,
                        selected: _tabs.index == 0,
                      ),
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
  const _OverviewTab({
    required this.workspace,
    this.onLeave,
    this.selected = false,
  });
  final WorkspaceEntity? workspace;
  final VoidCallback? onLeave;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ws = workspace;
    if (ws == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kWideMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Card ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: selected
                    ? BoxDecoration(
                        gradient: AppColors.blueGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blue.withAlpha(60),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      )
                    : BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withAlpha(40),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              ws.name.isNotEmpty
                                  ? ws.name[0].toUpperCase()
                                  : 'W',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  if (ws.isVerified) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(25),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified_rounded,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Verified',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${ws.slug}',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 16),
                    // ── Inline stat pills ──────────────────────
                    Row(
                      children: [
                        _HeroPill(
                          icon: Icons.people_outline_rounded,
                          value: '${ws.memberCount}',
                          label: 'Members',
                        ),
                        const SizedBox(width: 20),
                        _HeroPill(
                          icon: Icons.poll_outlined,
                          value: '${ws.pollCount}',
                          label: 'Polls',
                        ),
                        const Spacer(),
                        _HeroPill(
                          icon: ws.isPublic
                              ? Icons.public_rounded
                              : Icons.lock_outline_rounded,
                          value: ws.isPublic ? 'Public' : 'Private',
                          label: 'Access',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Details section ───────────────────────────────
              Text(
                'WORKSPACE INFO',
                style: AppTypography.label.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.metallicBorder,
                    width: 0.8,
                  ),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'Type',
                      value: ws.workspaceType,
                    ),
                    const _RowDivider(),
                    _DetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Your Role',
                      value: ws.role,
                      valueColor: _roleColor(ws.role),
                    ),
                    const _RowDivider(),
                    _DetailRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Verified',
                      value: ws.isVerified ? 'Yes' : 'No',
                      valueColor: ws.isVerified
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                    const _RowDivider(),
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Joined',
                      value: ws.joinedOn,
                    ),
                    const _RowDivider(),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Created',
                      value: ws.createdOn,
                    ),
                  ],
                ),
              ),
              if (onLeave != null) ...[
                const SizedBox(height: 28),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: onLeave,
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    label: Builder(
                      builder: (context) => Text(
                        AppLocalizations.of(context).workspaceLeaveButton,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      side: BorderSide(
                        color: AppColors.error.withAlpha(120),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'owner':
        return AppColors.gold;
      default:
        return AppColors.blue;
    }
  }
}

// ── Hero stat pill (inside gradient card) ────────────────────────────────────
class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.blue.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: AppColors.blue),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.cardTitle.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 60, endIndent: 16, thickness: 0.6);
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
      return const _EmptyTabState(
        icon: Icons.people_outline_rounded,
        message: 'No active members yet',
        subtitle: 'Invite people to grow your workspace',
      );
    }

    final total = members.length;
    final approved = members.where((m) => m.status == 'Approved').length;
    final rejected = members.where((m) => m.isRejected).length;
    final declined = members.where((m) => m.isDeclined).length;

    return Column(
      children: [
        // ── Summary bar ──────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.blue.withAlpha(8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.metallicBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryCell(label: 'Total', count: total, color: AppColors.blue),
              _VerticalDivider(),
              _SummaryCell(
                label: 'Approved',
                count: approved,
                color: AppColors.success,
              ),
              _VerticalDivider(),
              _SummaryCell(
                label: 'Rejected',
                count: rejected,
                color: AppColors.error,
              ),
              _VerticalDivider(),
              _SummaryCell(
                label: 'Declined',
                count: declined,
                color: AppColors.warning,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
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

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppColors.metallicBorder);
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.captionSmall),
      ],
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
    final contact = member.email.isNotEmpty
        ? member.email
        : member.mobileNumber;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.metallicBorder, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_roleColor.withAlpha(40), _roleColor.withAlpha(20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: _roleColor.withAlpha(60), width: 1.5),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _roleColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + contact
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (contact.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(contact, style: AppTypography.caption),
                  ],
                ],
              ),
            ),
            // ── Badges ────────────────────────────────────
            if (member.status != 'Approved') ...[
              _RoleBadge(label: member.status, color: statusColor),
              const SizedBox(width: 6),
            ],
            _RoleBadge(label: member.role, color: _roleColor),
            // ── Admin menu ────────────────────────────────
            if (isAdmin) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) async {
                  if (value == 'remove') {
                    final cubit = context.read<WorkspaceCubit>();
                    final memberName = member.name;
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Remove Member'),
                        content: Text(
                          'Remove $memberName from the workspace? This cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        await cubit.removeMember(
                          workspaceId: workspaceId,
                          userId: member.userId,
                        );
                        cubit.loadMembers(workspaceId);
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
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_remove_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Remove',
                          style: AppTypography.body.copyWith(
                            color: AppColors.error,
                          ),
                        ),
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
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 10),
                        Text('Report', style: AppTypography.body),
                      ],
                    ),
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(70), width: 0.8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.6,
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
      return const _EmptyTabState(
        icon: Icons.inbox_outlined,
        message: 'No pending requests',
        subtitle: 'New join requests will appear here',
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
    final contact = member.email.isNotEmpty
        ? member.email
        : member.mobileNumber;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.metallicBorder, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.warning.withAlpha(60),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (contact.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(contact, style: AppTypography.caption),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 11,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pending approval',
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(70), width: 0.8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({
    required this.icon,
    required this.message,
    this.subtitle,
  });
  final IconData icon;
  final String message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
              child: Icon(icon, size: 34, color: AppColors.blue.withAlpha(100)),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.sectionHeading.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
