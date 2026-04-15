import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_state.dart';

class JoinWorkspaceScreen extends StatelessWidget {
  const JoinWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkspaceCubit()..loadPublicWorkspaces(),
      child: const _JoinWorkspaceView(),
    );
  }
}

class _JoinWorkspaceView extends StatefulWidget {
  const _JoinWorkspaceView();

  @override
  State<_JoinWorkspaceView> createState() => _JoinWorkspaceViewState();
}

class _JoinWorkspaceViewState extends State<_JoinWorkspaceView> {
  final _searchController = TextEditingController();

  // Public workspaces (default view)
  List<WorkspaceEntity> _publicWorkspaces = [];
  // Search API results
  List<WorkspaceSearchResultEntity> _searchResults = [];

  bool _isSearchMode = false;
  bool _verifiedOnly = false;

  // tracks workspace IDs that have already been requested
  final Set<int> _requested = {};
  // tracks workspace IDs with in-flight requests
  final Set<int> _processing = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(BuildContext context) {
    final query = _searchController.text.trim();
    if (query.isEmpty && !_verifiedOnly) {
      // Revert to public list
      setState(() => _isSearchMode = false);
      context.read<WorkspaceCubit>().loadPublicWorkspaces();
    } else {
      setState(() => _isSearchMode = true);
      context.read<WorkspaceCubit>().searchWorkspaces(
        search: query.isNotEmpty ? query : null,
        isVerified: _verifiedOnly ? true : null,
      );
    }
  }

  void _onClear(BuildContext context) {
    _searchController.clear();
    setState(() {
      _isSearchMode = false;
      _verifiedOnly = false;
    });
    context.read<WorkspaceCubit>().loadPublicWorkspaces();
  }

  void _toggleVerified(BuildContext context, bool value) {
    setState(() => _verifiedOnly = value);
    _onSearch(context);
  }

  void _requestJoin(BuildContext context, int workspaceId) {
    setState(() => _processing.add(workspaceId));
    context.read<WorkspaceCubit>().requestJoinWorkspace(workspaceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join a Workspace')),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _onSearch(context),
              decoration: InputDecoration(
                hintText: 'Search by name…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _onClear(context),
                      )
                    : null,
              ),
            ),
          ),

          // ── Filter chips ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Verified only'),
                  selected: _verifiedOnly,
                  onSelected: (v) => _toggleVerified(context, v),
                  avatar: const Icon(Icons.verified_rounded, size: 14),
                  selectedColor: AppColors.blue.withAlpha(30),
                  checkmarkColor: AppColors.blue,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: _verifiedOnly
                        ? AppColors.blue
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // ── List ───────────────────────────────────────────
          Expanded(
            child: BlocConsumer<WorkspaceCubit, WorkspaceState>(
              listener: (context, state) {
                if (state is PublicWorkspacesLoaded) {
                  setState(() => _publicWorkspaces = state.workspaces);
                } else if (state is WorkspaceSearchResultsLoaded) {
                  setState(() => _searchResults = state.results);
                } else if (state is WorkspaceActionSuccess) {
                  if (_processing.isNotEmpty) {
                    final id = _processing.first;
                    setState(() {
                      _requested.add(id);
                      _processing.remove(id);
                    });
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else if (state is WorkspaceError) {
                  setState(() => _processing.clear());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is WorkspaceLoading;

                if (_isSearchMode) {
                  // ── Search results ────────────────────────
                  if (isLoading && _searchResults.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_searchResults.isEmpty) {
                    return _EmptyState(hasSearch: true);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final ws = _searchResults[i];
                      return _SearchResultCard(
                        workspace: ws,
                        isProcessing: _processing.contains(ws.workspaceId),
                        isRequested: _requested.contains(ws.workspaceId),
                        onJoin: () => _requestJoin(context, ws.workspaceId),
                      );
                    },
                  );
                } else {
                  // ── Public workspaces ─────────────────────
                  if (isLoading && _publicWorkspaces.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_publicWorkspaces.isEmpty) {
                    return _EmptyState(hasSearch: false);
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<WorkspaceCubit>().loadPublicWorkspaces(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: _publicWorkspaces.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final ws = _publicWorkspaces[i];
                        return _WorkspaceJoinCard(
                          workspace: ws,
                          isProcessing: _processing.contains(ws.workspaceId),
                          isRequested: _requested.contains(ws.workspaceId),
                          onJoin: () => _requestJoin(context, ws.workspaceId),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch});
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspaces_outlined,
              size: 72,
              color: AppColors.textFaint,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No workspaces found' : 'No public workspaces',
              style: AppTypography.sectionHeading,
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Try a different search term'
                  : 'There are no public workspaces available to join right now',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search result card ─────────────────────────────────────────

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.workspace,
    required this.isProcessing,
    required this.isRequested,
    required this.onJoin,
  });

  final WorkspaceSearchResultEntity workspace;
  final bool isProcessing;
  final bool isRequested;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
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
            const SizedBox(width: 12),

            // Info
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
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.blue,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    workspace.workspaceTypeName,
                    style: AppTypography.caption.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 13,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workspace.memberCount} members',
                        style: AppTypography.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (workspace.verificationStatusName.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: workspace.isVerified
                                ? AppColors.success.withAlpha(20)
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            workspace.verificationStatusName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: workspace.isVerified
                                  ? AppColors.success
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            _JoinButton(
              isProcessing: isProcessing,
              isRequested: isRequested,
              onJoin: onJoin,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Workspace join card ────────────────────────────────────────

class _WorkspaceJoinCard extends StatelessWidget {
  const _WorkspaceJoinCard({
    required this.workspace,
    required this.isProcessing,
    required this.isRequested,
    required this.onJoin,
  });

  final WorkspaceEntity workspace;
  final bool isProcessing;
  final bool isRequested;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
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
            const SizedBox(width: 12),

            // Info
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
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.blue,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    workspace.workspaceType,
                    style: AppTypography.caption.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 13,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workspace.memberCount} members',
                        style: AppTypography.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.poll_outlined,
                        size: 13,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workspace.pollCount} polls',
                        style: AppTypography.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Action button
            _JoinButton(
              isProcessing: isProcessing,
              isRequested: isRequested,
              onJoin: onJoin,
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({
    required this.isProcessing,
    required this.isRequested,
    required this.onJoin,
  });

  final bool isProcessing;
  final bool isRequested;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    if (isProcessing) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (isRequested) {
      return Chip(
        label: const Text('Requested'),
        labelStyle: TextStyle(
          fontSize: 11,
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.success.withAlpha(20),
        side: BorderSide(color: AppColors.success.withAlpha(60)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );
    }
    return FilledButton(
      onPressed: onJoin,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text('Join'),
    );
  }
}
