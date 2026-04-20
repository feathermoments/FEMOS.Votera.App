import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/l10n/app_localizations.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/core/widgets/gradient_app_bar.dart';
import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_state.dart';

class AddWorkspaceScreen extends StatelessWidget {
  const AddWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkspaceCubit()..loadWorkspaceTypes(),
      child: const _AddWorkspaceView(),
    );
  }
}

class _AddWorkspaceView extends StatefulWidget {
  const _AddWorkspaceView();

  @override
  State<_AddWorkspaceView> createState() => _AddWorkspaceViewState();
}

class _AddWorkspaceViewState extends State<_AddWorkspaceView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  int? _typeId;
  bool _isPublic = true;
  bool _autoPublicJoin = false;
  List<WorkspaceTypeEntity> _types = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_typeId == null) return;
    context.read<WorkspaceCubit>().createWorkspace(
      name: _nameCtrl.text.trim(),
      workspaceTypeId: _typeId!,
      isPublic: _isPublic,
      autoPublicJoin: _isPublic ? _autoPublicJoin : false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspaceCubit, WorkspaceState>(
      listener: (context, state) {
        if (state is WorkspaceTypesLoaded) {
          setState(() {
            _types = state.types;
            if (_types.isNotEmpty) _typeId = _types.first.workspaceTypeId;
          });
        } else if (state is WorkspaceActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is WorkspaceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: GradientAppBar(
          title: AppLocalizations.of(context).workspaceAddTitle,
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header card ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.workspaces_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Workspace',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Create a space to manage polls with your team',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // ── Name ─────────────────────────────────────
                    Text('Workspace Name', style: AppTypography.sectionHeading),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Acme Corp, Dev Team',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (v.trim().length < 3) {
                          return 'At least 3 characters required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // ── Type ─────────────────────────────────────
                    Text('Workspace Type', style: AppTypography.sectionHeading),
                    const SizedBox(height: 8),
                    if (_types.isEmpty)
                      const SizedBox(
                        height: 56,
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        initialValue: _typeId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _types
                            .map(
                              (t) => DropdownMenuItem<int>(
                                value: t.workspaceTypeId,
                                child: Text(t.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _typeId = v),
                      ),
                    const SizedBox(height: 20),
                    // ── Visibility ───────────────────────────────
                    Text('Visibility', style: AppTypography.sectionHeading),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.metallicBorder,
                          width: 0.8,
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        title: Text(
                          'Public Workspace',
                          style: AppTypography.cardTitle,
                        ),
                        subtitle: Text(
                          _isPublic
                              ? 'Anyone can find and request to join'
                              : 'Only invited members can join',
                          style: AppTypography.caption,
                        ),
                        secondary: Icon(
                          _isPublic
                              ? Icons.public_rounded
                              : Icons.lock_outline_rounded,
                          color: _isPublic
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                        value: _isPublic,
                        activeThumbColor: AppColors.blue,
                        onChanged: (v) => setState(() {
                          _isPublic = v;
                          if (!v) _autoPublicJoin = false;
                        }),
                      ),
                    ),
                    if (_isPublic) ...[
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.metallicBorder,
                            width: 0.8,
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(
                            'Auto Public Join',
                            style: AppTypography.cardTitle,
                          ),
                          subtitle: Text(
                            _autoPublicJoin
                                ? 'Users are joined automatically without approval'
                                : 'Users must request to join',
                            style: AppTypography.caption,
                          ),
                          secondary: Icon(
                            _autoPublicJoin
                                ? Icons.how_to_reg_rounded
                                : Icons.pending_actions_rounded,
                            color: _autoPublicJoin
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                          value: _autoPublicJoin,
                          activeThumbColor: AppColors.blue,
                          onChanged: (v) => setState(() => _autoPublicJoin = v),
                        ),
                      ),
                    ],
                    const SizedBox(height: 36),
                    // ── Submit ───────────────────────────────────
                    BlocBuilder<WorkspaceCubit, WorkspaceState>(
                      builder: (context, state) {
                        return SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: state is WorkspaceLoading
                                ? null
                                : _submit,
                            icon: state is WorkspaceLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.workspaces_rounded),
                            label: Text(
                              state is WorkspaceLoading
                                  ? 'Creating...'
                                  : 'Create Workspace',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
