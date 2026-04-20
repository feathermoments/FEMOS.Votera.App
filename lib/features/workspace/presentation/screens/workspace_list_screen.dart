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

class WorkspaceListScreen extends StatelessWidget {
  const WorkspaceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkspaceCubit()..loadUserWorkspaces(),
      child: const _WorkspaceListView(),
    );
  }
}

class _WorkspaceListView extends StatelessWidget {
  const _WorkspaceListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: AppLocalizations.of(context).workspaceListTitle,
        actions: [
          IconButton(
            tooltip: 'Join a workspace',
            icon: const Icon(Icons.group_add_outlined, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.joinWorkspace),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(context),
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<WorkspaceCubit, WorkspaceState>(
        listener: (context, state) {
          if (state is WorkspaceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkspaceInitial || state is WorkspaceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WorkspaceListLoaded) {
            if (state.workspaces.isEmpty) {
              return _EmptyState(onAdd: () => _openAdd(context));
            }
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<WorkspaceCubit>().loadUserWorkspaces(),
              child: context.isWide
                  ? GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.isDesktop ? 3 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.0,
                      ),
                      itemCount: state.workspaces.length,
                      itemBuilder: (context, i) {
                        final ws = state.workspaces[i];
                        return _WorkspaceCard(
                          workspace: ws,
                          onTap: () => Navigator.pushNamed(
                            context,
                            RouteNames.workspaceDetail,
                            arguments: ws.workspaceId,
                          ),
                        );
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: state.workspaces.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final ws = state.workspaces[i];
                        return _WorkspaceCard(
                          workspace: ws,
                          onTap: () => Navigator.pushNamed(
                            context,
                            RouteNames.workspaceDetail,
                            arguments: ws.workspaceId,
                          ),
                        );
                      },
                    ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openAdd(BuildContext context) async {
    final created = await Navigator.pushNamed(context, RouteNames.addWorkspace);
    if (created == true && context.mounted) {
      context.read<WorkspaceCubit>().loadUserWorkspaces();
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

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
              child: Icon(
                Icons.workspaces_outlined,
                size: 34,
                color: AppColors.blue.withAlpha(100),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No workspaces yet',
              style: AppTypography.sectionHeading.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create a workspace to start managing polls with your team',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                AppLocalizations.of(context).workspaceListCreateButton,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({required this.workspace, required this.onTap});
  final WorkspaceEntity workspace;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.metallicBorder, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    workspace.name.isNotEmpty
                        ? workspace.name[0].toUpperCase()
                        : 'W',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            workspace.name,
                            style: AppTypography.cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (workspace.isVerified)
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.blue,
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _Badge(
                          label: workspace.role.toUpperCase(),
                          color: AppColors.blue,
                        ),
                        const SizedBox(width: 6),
                        _Badge(
                          label: workspace.isPublic ? 'Public' : 'Private',
                          color: workspace.isPublic
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        _Badge(
                          label: workspace.workspaceType,
                          color: AppColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${workspace.memberCount}',
                          style: AppTypography.captionSmall,
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.poll_outlined,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${workspace.pollCount} polls',
                          style: AppTypography.captionSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
