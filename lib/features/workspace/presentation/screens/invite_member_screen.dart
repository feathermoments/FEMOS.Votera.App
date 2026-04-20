import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/l10n/app_localizations.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/widgets/gradient_app_bar.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_state.dart';

class InviteMemberScreen extends StatelessWidget {
  const InviteMemberScreen({super.key, required this.workspaceId});
  final int workspaceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkspaceCubit(),
      child: _InviteMemberView(workspaceId: workspaceId),
    );
  }
}

class _InviteMemberView extends StatefulWidget {
  const _InviteMemberView({required this.workspaceId});
  final int workspaceId;

  @override
  State<_InviteMemberView> createState() => _InviteMemberViewState();
}

class _InviteMemberViewState extends State<_InviteMemberView> {
  final _formKey = GlobalKey<FormState>();
  final _contactCtrl = TextEditingController();
  String _contactType = 'mobile';

  @override
  void dispose() {
    _contactCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<WorkspaceCubit>().inviteMember(
      workspaceId: widget.workspaceId,
      contact: _contactCtrl.text.trim(),
      contactType: _contactType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspaceCubit, WorkspaceState>(
      listener: (context, state) {
        if (state is WorkspaceActionSuccess) {
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
          title: AppLocalizations.of(context).inviteMemberTitle,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Info banner ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withAlpha(12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.blue.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'An invite will be sent to the member. They will need to verify and join.',
                              style: AppTypography.caption.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // ── Contact type ─────────────────────────────
                    Text('Contact Type', style: AppTypography.sectionHeading),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeTile(
                            icon: Icons.phone_outlined,
                            label: 'Mobile',
                            selected: _contactType == 'mobile',
                            onTap: () => setState(() {
                              _contactType = 'mobile';
                              _contactCtrl.clear();
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TypeTile(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            selected: _contactType == 'email',
                            onTap: () => setState(() {
                              _contactType = 'email';
                              _contactCtrl.clear();
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // ── Contact field ────────────────────────────
                    Text(
                      _contactType == 'mobile'
                          ? 'Mobile Number'
                          : 'Email Address',
                      style: AppTypography.sectionHeading,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contactCtrl,
                      keyboardType: _contactType == 'mobile'
                          ? TextInputType.phone
                          : TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      inputFormatters: _contactType == 'mobile'
                          ? <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ]
                          : <TextInputFormatter>[],
                      decoration: InputDecoration(
                        hintText: _contactType == 'mobile'
                            ? '+91 9999999999'
                            : 'member@example.com',
                        prefixIcon: Icon(
                          _contactType == 'mobile'
                              ? Icons.phone_outlined
                              : Icons.email_outlined,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'This field is required';
                        }
                        final val = v.trim();
                        if (_contactType == 'email') {
                          final emailRegex = RegExp(
                            r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}",
                          );
                          if (!emailRegex.hasMatch(val)) {
                            return 'Enter a valid email address';
                          }
                        } else {
                          // allow digits and common separators, but validate digit count
                          final digits = val.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 7 || digits.length > 10) {
                            return 'Enter a valid mobile number (7-10 digits)';
                          }
                        }
                        return null;
                      },
                    ),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: state is WorkspaceLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded),
                            label: Text(
                              state is WorkspaceLoading
                                  ? 'Sending...'
                                  : 'Send Invitation',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.blue.withAlpha(15)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.blue
                : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.blue : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.cardTitle.copyWith(
                color: selected
                    ? AppColors.blue
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
