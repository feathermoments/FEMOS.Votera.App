import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:votera_app/core/l10n/app_localizations.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/core/widgets/gradient_app_bar.dart';
import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_state.dart';

class WorkspaceInviteLinksScreen extends StatelessWidget {
  const WorkspaceInviteLinksScreen({
    super.key,
    required this.workspaceId,
    required this.role,
  });
  final int workspaceId;
  final String role;

  bool get _isAdmin => role == 'Admin' || role == 'Owner';

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        appBar: GradientAppBar(
          title: AppLocalizations.of(context).workspaceInviteLinksTitle,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 36,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Access Restricted',
                  style: AppTypography.sectionHeading.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Only Admins and Owners can manage invite links.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return BlocProvider(
      create: (_) => WorkspaceCubit()..loadWorkspaceInviteLinks(workspaceId),
      child: _InviteLinksView(workspaceId: workspaceId),
    );
  }
}

class _InviteLinksView extends StatefulWidget {
  const _InviteLinksView({required this.workspaceId});
  final int workspaceId;

  @override
  State<_InviteLinksView> createState() => _InviteLinksViewState();
}

class _InviteLinksViewState extends State<_InviteLinksView> {
  List<WorkspaceInviteLinkEntity> _links = [];

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WorkspaceCubit>(),
        child: _CreateInviteLinkSheet(workspaceId: widget.workspaceId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkspaceCubit, WorkspaceState>(
      listener: (context, state) {
        if (state is WorkspaceInviteLinksLoaded) {
          setState(() => _links = state.links);
        } else if (state is WorkspaceInviteLinkCreated) {
          Navigator.pop(context); // close bottom sheet
          context.read<WorkspaceCubit>().loadWorkspaceInviteLinks(
            widget.workspaceId,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invite link created successfully'),
              backgroundColor: AppColors.success,
            ),
          );
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
        return Scaffold(
          appBar: GradientAppBar(
            title: AppLocalizations.of(context).workspaceInviteLinksTitle,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showCreateSheet,
            backgroundColor: AppColors.blue,
            icon: const Icon(Icons.add_link_rounded, color: Colors.white),
            label: const Text(
              'Create Link',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Builder(
            builder: (_) {
              if (state is WorkspaceLoading && _links.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_links.isEmpty) {
                return _EmptyState(onCreateTap: _showCreateSheet);
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WorkspaceCubit>().loadWorkspaceInviteLinks(
                    widget.workspaceId,
                  );
                },
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    80 + MediaQuery.paddingOf(context).bottom,
                  ),
                  itemCount: _links.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _InviteLinkCard(link: _links[i]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateTap});
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.blue.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.link_rounded,
                size: 36,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No invite links yet',
              style: AppTypography.sectionHeading.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a shareable link to let others join this workspace.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add_link_rounded),
              label: Text(
                AppLocalizations.of(context).workspaceInviteLinksCreateButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Invite link card ──────────────────────────────────────────────────────────

class _InviteLinkCard extends StatelessWidget {
  const _InviteLinkCard({required this.link});
  final WorkspaceInviteLinkEntity link;

  @override
  Widget build(BuildContext context) {
    final isExpired = _isExpired(link.expiryDate);
    final isExhausted = link.remainingUsage == 0 && link.maxUsage > 0;
    final statusLower = link.status.toLowerCase();
    final isActive =
        (statusLower == 'active' || statusLower == '') &&
        !isExpired &&
        !isExhausted;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.metallicBorder, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ───────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.success.withAlpha(20)
                        : AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive
                        ? 'Active'
                        : (isExpired
                              ? 'Expired'
                              : (isExhausted ? 'Exhausted' : 'Inactive')),
                    style: AppTypography.caption.copyWith(
                      color: isActive ? AppColors.successDark : AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Link row ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.metallicLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.metallicBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      link.inviteLink.isNotEmpty
                          ? link.inviteLink
                          : link.inviteCode,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'JetBrainsMono',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Stats row ────────────────────────────────────
            Row(
              children: [
                _Chip(
                  icon: Icons.calendar_today_outlined,
                  label: 'Expires ${_formatDate(link.expiryDate)}',
                ),
                const SizedBox(width: 8),
                _Chip(
                  icon: Icons.people_outline_rounded,
                  label:
                      '${link.usageCount}/${link.maxUsage == 0 ? '∞' : link.maxUsage} used',
                ),
                const SizedBox(width: 8),
                _Chip(
                  icon: Icons.group_add_outlined,
                  label: '${link.remainingUsage} remaining',
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Actions row ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyLink(context),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(
                      AppLocalizations.of(context).workspaceInviteLinksCopy,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isActive ? () => _shareLink(context) : null,
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: Text(
                      AppLocalizations.of(context).workspaceInviteLinksShare,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

  void _copyLink(BuildContext context) {
    final text = link.inviteLink.isNotEmpty ? link.inviteLink : link.inviteCode;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareLink(BuildContext context) {
    final text = link.inviteLink.isNotEmpty ? link.inviteLink : link.inviteCode;
    Share.share(
      'Join my workspace on Votera! Use this invite link: $text',
      subject: 'Workspace Invite',
    );
  }

  bool _isExpired(String dateStr) {
    if (dateStr.isEmpty) return false;
    try {
      final expiry = DateTime.parse(dateStr);
      return expiry.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '—';
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

// ── Create invite link bottom sheet ──────────────────────────────────────────

class _CreateInviteLinkSheet extends StatefulWidget {
  const _CreateInviteLinkSheet({required this.workspaceId});
  final int workspaceId;

  @override
  State<_CreateInviteLinkSheet> createState() => _CreateInviteLinkSheetState();
}

class _CreateInviteLinkSheetState extends State<_CreateInviteLinkSheet> {
  final _formKey = GlobalKey<FormState>();
  final _maxUsageCtrl = TextEditingController(text: '10');
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  String _roleToAssign = 'Member';

  static const _roles = ['Member', 'Admin', 'Moderator'];

  @override
  void dispose() {
    _maxUsageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final expiryStr =
        '${_expiryDate.year}-${_expiryDate.month.toString().padLeft(2, '0')}-${_expiryDate.day.toString().padLeft(2, '0')}';
    context.read<WorkspaceCubit>().createInviteLink(
      workspaceId: widget.workspaceId,
      expiryDate: expiryStr,
      maxUsage: int.tryParse(_maxUsageCtrl.text.trim()) ?? 10,
      roleToAssign: _roleToAssign,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ──────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.metallicBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Create Invite Link', style: AppTypography.screenTitle),
          const SizedBox(height: 4),
          Text(
            'Generate a shareable link for others to join this workspace.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Expiry date ──────────────────────────────
                Text('Expiry Date', style: AppTypography.sectionHeading),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.metallicBorder),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.whiteInput,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                          style: AppTypography.body,
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ── Max usage ────────────────────────────────
                Text('Max Usage', style: AppTypography.sectionHeading),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _maxUsageCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 10  (0 = unlimited)',
                    prefixIcon: Icon(Icons.people_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter max usage (0 for unlimited)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // ── Role to assign ───────────────────────────
                Text('Role to Assign', style: AppTypography.sectionHeading),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _roleToAssign,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _roleToAssign = v);
                  },
                ),
                const SizedBox(height: 28),
                // ── Submit ───────────────────────────────────
                BlocBuilder<WorkspaceCubit, WorkspaceState>(
                  builder: (context, state) {
                    final loading = state is WorkspaceLoading;
                    return SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                        ),
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add_link_rounded),
                        label: Text(
                          loading ? 'Creating...' : 'Create Invite Link',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
