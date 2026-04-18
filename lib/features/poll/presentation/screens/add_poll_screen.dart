import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/router/route_names.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/features/category/domain/entities/category_entity.dart';
import 'package:votera_app/features/category/presentation/cubit/category_cubit.dart';
import 'package:votera_app/features/poll/presentation/cubit/poll_cubit.dart';
import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_state.dart';

class AddPollScreen extends StatelessWidget {
  const AddPollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PollCubit()),
        BlocProvider(create: (_) => CategoryCubit()),
        BlocProvider(create: (_) => WorkspaceCubit()..loadUserWorkspaces()),
      ],
      child: const _AddPollForm(),
    );
  }
}

class _AddPollForm extends StatefulWidget {
  const _AddPollForm();

  @override
  State<_AddPollForm> createState() => _AddPollFormState();
}

class _AddPollFormState extends State<_AddPollForm> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];

  int? _workspaceId;
  int? _categoryId;
  String _visibility = 'public';
  bool _isAnonymous = true;
  DateTime? _expiryDate;

  static const _visibilityOptions = ['public', 'private', 'workspace'];
  static const _maxOptions = 8;

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionCtrls.length >= _maxOptions) return;
    setState(() => _optionCtrls.add(TextEditingController()));
  }

  void _removeOption(int index) {
    if (_optionCtrls.length <= 2) return;
    setState(() {
      _optionCtrls[index].dispose();
      _optionCtrls.removeAt(index);
    });
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_workspaceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a workspace')),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final options = _optionCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    context.read<PollCubit>().createPoll(
      workspaceId: _workspaceId!,
      categoryId: _categoryId!,
      question: _questionCtrl.text.trim(),
      options: options,
      visibility: _visibility,
      expiryDate: _expiryDate?.toIso8601String(),
      isAnonymous: _isAnonymous,
    );
  }

  void _showNoWorkspaceDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.whiteCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.blueGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: const Column(
            children: [
              Icon(Icons.workspaces_rounded, size: 44, color: Colors.white),
              SizedBox(height: 10),
              Text(
                'No Workspace Found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'You need to create a workspace before adding a poll. Would you like to add one now?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.metallicBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    final created = await Navigator.pushNamed(
                      context,
                      RouteNames.addWorkspace,
                    );
                    if (created == true && context.mounted) {
                      context.read<WorkspaceCubit>().loadUserWorkspaces();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Workspace',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Poll')),
      body: BlocListener<WorkspaceCubit, WorkspaceState>(
        listener: (context, state) {
          if (state is WorkspaceListLoaded) {
            final adminWorkspaces = state.workspaces
                .where((w) => w.role.toLowerCase() == 'admin')
                .toList();
            if (adminWorkspaces.isEmpty) {
              _showNoWorkspaceDialog(context);
            }
          }
        },
        child: BlocConsumer<PollCubit, PollState>(
          listenWhen: (_, s) => s is PollActionSuccess || s is PollError,
          listener: (context, state) {
            if (state is PollActionSuccess) {
              Navigator.pop(context, true);
            } else if (state is PollError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, pollState) {
            final isLoading = pollState is PollLoading;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // ── Question ────────────────────────────────────────
                      _FieldLabel('Question'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _questionCtrl,
                        maxLines: 3,
                        decoration: _inputDecoration('Enter your question...'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Question is required'
                            : null,
                      ),
                      const SizedBox(height: 18),

                      // ── Workspace ───────────────────────────────────────
                      _FieldLabel('Workspace'),
                      const SizedBox(height: 6),
                      BlocBuilder<WorkspaceCubit, WorkspaceState>(
                        builder: (context, state) {
                          final workspaces = state is WorkspaceListLoaded
                              ? state.workspaces
                                    .where(
                                      (w) => w.role.toLowerCase() == 'admin',
                                    )
                                    .toList()
                              : <WorkspaceEntity>[];
                          return DropdownButtonFormField<int>(
                            initialValue: _workspaceId,
                            decoration: _inputDecoration('Select workspace'),
                            items: workspaces
                                .map(
                                  (w) => DropdownMenuItem(
                                    value: w.workspaceId,
                                    child: Text(w.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                _workspaceId = v;
                                _categoryId = null;
                              });
                              if (v != null) {
                                context.read<CategoryCubit>().loadCategories(v);
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 18),

                      // ── Category ────────────────────────────────────────
                      _FieldLabel('Category'),
                      const SizedBox(height: 6),
                      BlocBuilder<CategoryCubit, CategoryState>(
                        builder: (context, state) {
                          final cats = state is CategoryLoaded
                              ? state.categories
                              : <CategoryEntity>[];
                          return DropdownButtonFormField<int>(
                            initialValue: _categoryId,
                            decoration: _inputDecoration('Select category'),
                            items: cats
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.categoryId,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _categoryId = v),
                          );
                        },
                      ),
                      const SizedBox(height: 18),

                      // ── Visibility ──────────────────────────────────────
                      _FieldLabel('Visibility'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _visibility,
                        decoration: _inputDecoration('Select visibility'),
                        items: _visibilityOptions
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(_capitalize(v)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _visibility = v ?? _visibility),
                      ),
                      const SizedBox(height: 18),

                      // ── Options ─────────────────────────────────────────
                      Row(
                        children: [
                          _FieldLabel('Options'),
                          const Spacer(),
                          Text(
                            '${_optionCtrls.length}/$_maxOptions',
                            style: AppTypography.captionSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...List.generate(_optionCtrls.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _optionCtrls[i],
                                  decoration: _inputDecoration(
                                    'Option ${i + 1}',
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Option cannot be empty'
                                      : null,
                                ),
                              ),
                              if (_optionCtrls.length > 2)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: GestureDetector(
                                    onTap: () => _removeOption(i),
                                    child: const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      if (_optionCtrls.length < _maxOptions)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _addOption,
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 18,
                            ),
                            label: const Text('Add Option'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.blue,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // ── Anonymous ───────────────────────────────────────
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'Anonymous Voting',
                            style: AppTypography.bodySmall,
                          ),
                          subtitle: Text(
                            'Voters\' identities will be hidden',
                            style: AppTypography.captionSmall,
                          ),
                          value: _isAnonymous,
                          activeThumbColor: AppColors.blue,
                          onChanged: (v) => setState(() => _isAnonymous = v),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Expiry Date ─────────────────────────────────────
                      _FieldLabel('Expiry Date (optional)'),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickExpiry,
                        borderRadius: BorderRadius.circular(10),
                        child: InputDecorator(
                          decoration: _inputDecoration('Tap to pick a date'),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _expiryDate != null
                                      ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                                      : 'No expiry (open-ended)',
                                  style: _expiryDate != null
                                      ? AppTypography.bodySmall
                                      : AppTypography.captionSmall,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                              if (_expiryDate != null)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _expiryDate = null),
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Submit ──────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Create Poll',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.captionSmall,
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppTypography.label);
}
