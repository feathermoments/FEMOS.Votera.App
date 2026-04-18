import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/core/l10n/app_localizations.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/storage/secure_storage.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_state.dart';

/// Entry point — checks auth then delegates to the inner view.
class WorkspaceJoinInviteScreen extends StatelessWidget {
  const WorkspaceJoinInviteScreen({super.key, required this.inviteCode});

  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkspaceCubit(),
      child: _JoinInviteGate(inviteCode: inviteCode),
    );
  }
}

/// Checks token; if missing redirects to login, otherwise validates code.
class _JoinInviteGate extends StatefulWidget {
  const _JoinInviteGate({required this.inviteCode});

  final String inviteCode;

  @override
  State<_JoinInviteGate> createState() => _JoinInviteGateState();
}

class _JoinInviteGateState extends State<_JoinInviteGate> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndValidate();
  }

  Future<void> _checkAuthAndValidate() async {
    final storage = sl<SecureStorageService>();
    final hasToken = await storage.hasToken();

    if (!mounted) return;

    if (!hasToken) {
      // Navigate to login, telling it to come back here after auth.
      Navigator.pushReplacementNamed(
        context,
        RouteNames.login,
        arguments: {
          'nextRoute': RouteNames.workspaceJoinInvite,
          'nextArgs': widget.inviteCode,
        },
      );
      return;
    }

    // Logged in — validate the invite code.
    context.read<WorkspaceCubit>().validateInviteCode(widget.inviteCode);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkspaceCubit, WorkspaceState>(
      listener: (ctx, state) {
        if (state is WorkspaceActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            ctx,
            RouteNames.dashboard,
            (r) => false,
          );
        } else if (state is WorkspaceError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (ctx, state) {
        if (state is WorkspaceLoading || state is WorkspaceInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is WorkspaceError) {
          return _ErrorView(
            message: state.message,
            onClose: () => Navigator.pop(ctx),
            onRetry: () => ctx.read<WorkspaceCubit>().validateInviteCode(
              widget.inviteCode,
            ),
          );
        }

        if (state is WorkspaceInviteValidated) {
          return _InviteDetailView(
            data: state.data,
            isJoining: false,
            onJoin: () => state.data.isValid
                ? ctx.read<WorkspaceCubit>().joinViaInviteCode(
                    widget.inviteCode,
                  )
                : ctx.read<WorkspaceCubit>().requestJoinWorkspace(
                    state.data.workspaceId,
                  ),
            onClose: () => Navigator.pop(ctx),
          );
        }

        // Joining in progress — overlay a loading state on the detail card.
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

// ── Detail card ───────────────────────────────────────────────────────────────

class _InviteDetailView extends StatelessWidget {
  const _InviteDetailView({
    required this.data,
    required this.isJoining,
    required this.onJoin,
    required this.onClose,
  });

  final WorkspaceInviteValidationEntity data;
  final bool isJoining;
  final VoidCallback onJoin;
  final VoidCallback onClose;

  String _formatDate(String raw) {
    if (raw.isEmpty) return '—';
    try {
      // API returns 'dd-MM-yyyy HH:mm:ss'
      final parts = raw.split(' ');
      final dateParts = parts[0].split('-');
      if (dateParts.length == 3) {
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[month - 1]} $day, $year';
      }
      // Fallback: try ISO parse
      final dt = DateTime.parse(raw).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.whiteSurface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).workspaceJoinInviteTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: onClose,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Workspace header ──────────────────────────────────
              Center(
                child: Column(
                  children: [
                    _WorkspaceLogo(logoUrl: data.workspaceLogo),
                    const SizedBox(height: 16),
                    Text(
                      data.workspaceName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).workspaceInvitedAsRole(data.roleToAssign),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Details card ──────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.metallicBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // _InfoRow(
                    //   icon: Icons.tag_rounded,
                    //   label: 'Invite ID',
                    //   value: '#${data.inviteId}',
                    // ),
                    // _Divider(),
                    // _InfoRow(
                    //   icon: Icons.work_outline_rounded,
                    //   label: 'Workspace ID',
                    //   value: '#${data.workspaceId}',
                    // ),
                    _Divider(),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: AppLocalizations.of(
                        context,
                      ).workspaceInviteExpiresLabel,
                      value: _formatDate(data.expiryDate),
                      valueColor: _isExpired(data.expiryDate)
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                    _Divider(),
                    _InfoRow(
                      icon: Icons.group_rounded,
                      label: AppLocalizations.of(
                        context,
                      ).workspaceInviteUsageLabel,
                      value: '${data.usageCount} / ${data.maxUsage}',
                      trailing: _UsageBar(
                        used: data.usageCount,
                        max: data.maxUsage,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Invalid invite message ────────────────────────────
              if (!data.isValid) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withAlpha(80)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          data.message,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Join button ───────────────────────────────────────
              BlocBuilder<WorkspaceCubit, WorkspaceState>(
                builder: (ctx, state) {
                  final loading = state is WorkspaceLoading;
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              data.isValid
                                  ? AppLocalizations.of(
                                      ctx,
                                    ).workspaceInviteJoinButton
                                  : AppLocalizations.of(
                                      ctx,
                                    ).workspaceInviteSendRequestButton,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ── Close / Cancel button ─────────────────────────────
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.metallicBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).workspaceInviteCloseButton,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isExpired(String raw) {
    if (raw.isEmpty) return false;
    try {
      return DateTime.parse(raw).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}

// ── Workspace logo widget ─────────────────────────────────────────────────────

class _WorkspaceLogo extends StatelessWidget {
  const _WorkspaceLogo({required this.logoUrl});

  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.metallicLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.metallicBorder, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl.isNotEmpty
          ? Image.network(
              logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _LogoPlaceholder(),
            )
          : const _LogoPlaceholder(),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.workspaces_rounded,
      size: 36,
      color: AppColors.textMuted,
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.metallicBorder,
    );
  }
}

// ── Usage bar ─────────────────────────────────────────────────────────────────

class _UsageBar extends StatelessWidget {
  const _UsageBar({required this.used, required this.max});

  final int used;
  final int max;

  @override
  Widget build(BuildContext context) {
    final frac = max > 0 ? (used / max).clamp(0.0, 1.0) : 0.0;
    final color = frac >= 1.0
        ? AppColors.error
        : frac >= 0.8
        ? AppColors.warning
        : AppColors.success;
    return SizedBox(
      width: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: frac,
          backgroundColor: AppColors.metallicLight,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onClose,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).workspaceInviteErrorTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: onClose,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.link_off_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).workspaceInviteErrorHeading,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(
                AppLocalizations.of(context).workspaceInviteRetryButton,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClose,
              child: Text(
                AppLocalizations.of(context).workspaceInviteCloseButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
