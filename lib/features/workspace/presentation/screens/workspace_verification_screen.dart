import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_state.dart';

class WorkspaceVerificationScreen extends StatelessWidget {
  const WorkspaceVerificationScreen({super.key, required this.workspaceId});
  final int workspaceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkspaceCubit()..loadVerificationStatus(workspaceId),
      child: _WorkspaceVerificationView(workspaceId: workspaceId),
    );
  }
}

class _WorkspaceVerificationView extends StatefulWidget {
  const _WorkspaceVerificationView({required this.workspaceId});
  final int workspaceId;

  @override
  State<_WorkspaceVerificationView> createState() =>
      _WorkspaceVerificationViewState();
}

class _WorkspaceVerificationViewState
    extends State<_WorkspaceVerificationView> {
  final _formKey = GlobalKey<FormState>();
  final _domainCtrl = TextEditingController();

  @override
  void dispose() {
    _domainCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<WorkspaceCubit>().requestVerification(
      workspaceId: widget.workspaceId,
      companyDomain: _domainCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkspaceCubit, WorkspaceState>(
      listener: (context, state) {
        if (state is WorkspaceActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          // Reload verification status
          context.read<WorkspaceCubit>().loadVerificationStatus(
            widget.workspaceId,
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
          appBar: AppBar(title: const Text('Workspace Verification')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Status card ───────────────────────────────
                if (state is WorkspaceVerificationLoaded) ...[
                  _VerificationStatusCard(verification: state.verification),
                  const SizedBox(height: 24),
                ] else if (state is WorkspaceLoading) ...[
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Request form ──────────────────────────────
                Text(
                  'Request Verification',
                  style: AppTypography.sectionHeading,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info.withAlpha(40)),
                  ),
                  child: Text(
                    'Provide your company domain to get a verified badge on your workspace. Our team will review and approve it.',
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _domainCtrl,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Company Domain',
                          hintText: 'e.g. acmecorp.com',
                          prefixIcon: Icon(Icons.domain_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Domain is required';
                          }
                          if (!v.contains('.')) {
                            return 'Enter a valid domain (e.g. example.com)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: state is WorkspaceLoading ? null : _submit,
                          icon: state is WorkspaceLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.verified_user_outlined),
                          label: Text(
                            state is WorkspaceLoading
                                ? 'Submitting...'
                                : 'Submit for Verification',
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
      },
    );
  }
}

class _VerificationStatusCard extends StatelessWidget {
  const _VerificationStatusCard({required this.verification});
  final dynamic verification; // WorkspaceVerificationEntity

  @override
  Widget build(BuildContext context) {
    final isVerified = verification.isVerified as bool;
    final status = verification.statusName as String;
    final color = isVerified
        ? AppColors.success
        : status.toLowerCase().contains('pending')
        ? AppColors.warning
        : AppColors.textMuted;
    final icon = isVerified
        ? Icons.verified_rounded
        : status.toLowerCase().contains('pending')
        ? Icons.hourglass_top_rounded
        : Icons.info_outline_rounded;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verification Status', style: AppTypography.caption),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: AppTypography.sectionHeading.copyWith(color: color),
                  ),
                  if (isVerified && verification.reviewedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Approved on ${verification.reviewedAt}',
                      style: AppTypography.captionSmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
