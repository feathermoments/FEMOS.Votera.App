import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_state.dart';

class WorkspaceInboxScreen extends StatelessWidget {
  const WorkspaceInboxScreen({super.key, required this.userId});
  final int userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkspaceCubit()..loadInvites(),
      child: _WorkspaceInboxView(userId: userId),
    );
  }
}

class _WorkspaceInboxView extends StatefulWidget {
  const _WorkspaceInboxView({required this.userId});
  final int userId;

  @override
  State<_WorkspaceInboxView> createState() => _WorkspaceInboxViewState();
}

class _WorkspaceInboxViewState extends State<_WorkspaceInboxView> {
  List<WorkspaceInviteEntity> _invites = [];
  // tracks which workspaceIds are in mid-flight
  final Set<int> _processing = {};

  void _respond(BuildContext context, int workspaceId, bool isAccepted) {
    setState(() => _processing.add(workspaceId));
    context.read<WorkspaceCubit>().respondToInvite(
      workspaceId: workspaceId,
      userId: widget.userId,
      isAccepted: isAccepted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workspace Inbox')),
      body: BlocConsumer<WorkspaceCubit, WorkspaceState>(
        listener: (context, state) {
          if (state is WorkspaceInvitesLoaded) {
            setState(() => _invites = state.invites);
          } else if (state is WorkspaceActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload invites after responding
            context.read<WorkspaceCubit>().loadInvites();
          } else if (state is WorkspaceError) {
            final cubit = context.read<WorkspaceCubit>();
            setState(() => _processing.clear());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
            // restore invite list after error
            cubit.loadInvites();
          }
        },
        builder: (context, state) {
          final isLoading = state is WorkspaceLoading && _invites.isEmpty;
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_invites.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 64,
                    color: AppColors.textFaint,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No pending invites',
                    style: AppTypography.sectionHeading,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Workspace invitations will appear here',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<WorkspaceCubit>().loadInvites(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _invites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final invite = _invites[i];
                final busy = _processing.contains(invite.workspaceId);
                return _InviteCard(
                  invite: invite,
                  isBusy: busy,
                  onAccept: busy
                      ? null
                      : () => _respond(context, invite.workspaceId, true),
                  onDecline: busy
                      ? null
                      : () => _respond(context, invite.workspaceId, false),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.invite,
    required this.isBusy,
    required this.onAccept,
    required this.onDecline,
  });

  final WorkspaceInviteEntity invite;
  final bool isBusy;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.blueGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      invite.workspaceName.isNotEmpty
                          ? invite.workspaceName[0].toUpperCase()
                          : 'W',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
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
                        invite.workspaceName,
                        style: AppTypography.cardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Chip(
                            label: invite.workspaceTypeName,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 6),
                          _Chip(
                            label: invite.isPublic ? 'Public' : 'Private',
                            color: invite.isPublic
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          _Chip(label: invite.role, color: AppColors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
                if (invite.isVerified)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.blue,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Invited by + date ────────────────────────────
            if (invite.invitedByName.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Invited by ${invite.invitedByName}',
                    style: AppTypography.captionSmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(invite.invitedOn),
                  style: AppTypography.captionSmall,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Actions ──────────────────────────────────────
            if (isBusy)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw.replaceFirst(' ', 'T'));
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return raw;
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
