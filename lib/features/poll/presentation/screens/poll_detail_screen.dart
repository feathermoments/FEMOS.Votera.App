import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/core/responsive/responsive_utils.dart';
import 'package:votera_app/core/storage/secure_storage.dart';
import 'package:votera_app/core/theme/app_colors.dart';
import 'package:votera_app/core/theme/app_typography.dart';
import 'package:votera_app/core/widgets/gradient_app_bar.dart';
import 'package:votera_app/features/poll/domain/entities/poll_entity.dart';
import 'package:votera_app/features/poll/presentation/cubit/poll_cubit.dart';
import 'package:votera_app/core/config/app_config.dart';

class PollDetailScreen extends StatelessWidget {
  const PollDetailScreen({
    super.key,
    required this.pollId,
    required this.userId,
  });
  final int pollId;
  final int userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PollCubit()..loadPollDetail(pollId),
      child: _PollDetailView(pollId: pollId, userId: userId),
    );
  }
}

class _PollDetailView extends StatefulWidget {
  const _PollDetailView({required this.pollId, required this.userId});
  final int pollId;
  final int userId;

  @override
  State<_PollDetailView> createState() => _PollDetailViewState();
}

class _PollDetailViewState extends State<_PollDetailView> {
  PollDetailEntity? _detail;
  List<PollResultEntity> _results = [];
  int? _selectedOptionId;
  bool _isVoting = false;
  bool _isLoadingResults = false;
  bool _hasVoted = false;
  // Use a getter for expiry logic
  bool get _isExpired {
    final expiry = _detail?.expiryDate;
    if (expiry == null || expiry.isEmpty) return false;
    try {
      return DateTime.parse(expiry).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  late int _userId;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    if (_userId == 0) {
      sl<SecureStorageService>().getUserId().then((stored) {
        if (stored != null && stored != 0 && mounted) {
          setState(() => _userId = stored);
        }
      });
    }
  }

  void _castVote() {
    if (_selectedOptionId == null) return;
    setState(() => _isVoting = true);
    context.read<PollCubit>().castVote(
      pollId: widget.pollId,
      optionId: _selectedOptionId!,
    );
  }

  Future<void> _confirmAndCastVote() async {
    if (_selectedOptionId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirm Vote'),
        content: const Text(
          'Are you sure you want to submit? You can vote only once.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _castVote();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_hasVoted);
      },
      child: Scaffold(
        appBar: GradientAppBar(title: _detail?.workspaceName ?? 'Poll'),
        body: BlocConsumer<PollCubit, PollState>(
          listener: (context, state) async {
            if (state is PollDetailLoaded) {
              final votedEntry = state.poll.votes
                  .where((v) => v.userId == _userId)
                  .firstOrNull;
              setState(() {
                _detail = state.poll;
                _hasVoted = votedEntry != null;
                if (votedEntry != null) _selectedOptionId = votedEntry.optionId;
              });
              // If poll is expired, load results immediately
              if (_isExpired && _results.isEmpty) {
                setState(() => _isLoadingResults = true);
                context.read<PollCubit>().loadResults(widget.pollId);
              }
            } else if (state is PollResultsLoaded) {
              setState(() {
                _results = state.results;
                _isLoadingResults = false;
              });
            } else if (state is PollActionSuccess) {
              setState(() {
                _isVoting = false;
                _hasVoted = true;
              });
              if (!mounted) return;
              await showDialog<void>(
                context: context,
                builder: (dCtx) => AlertDialog(
                  backgroundColor: Colors.white,
                  contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.celebration_rounded,
                        size: 56,
                        color: AppColors.gold,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Thank you!',
                        style: AppTypography.sectionHeading.copyWith(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We truly appreciate you taking the time to vote. Your choice helps shape the outcome and makes a real difference to the community.',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.favorite_border, color: AppColors.gold),
                          SizedBox(width: 8),
                          Text(
                            'Your voice matters',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dCtx).pop(),
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                      ),
                      onPressed: () {
                        Navigator.of(dCtx).pop();
                        setState(() => _isLoadingResults = true);
                        context.read<PollCubit>().loadResults(widget.pollId);
                      },
                      child: const Text('View Results'),
                    ),
                  ],
                ),
              );
              // Load results right after voting (if user closed dialog without choosing View Results)
              if (!_isLoadingResults) {
                setState(() => _isLoadingResults = true);
                context.read<PollCubit>().loadResults(widget.pollId);
              }
            } else if (state is PollError) {
              setState(() {
                _isVoting = false;
                _isLoadingResults = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: AppConfig.toastDuration,
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (_detail == null) {
              return state is PollLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink();
            }

            // If poll is expired, always show results
            final showResults = _isExpired || _results.isNotEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Trust banner ──────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withAlpha(10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.blue.withAlpha(40),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.blue,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTypography.captionSmall.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Your voice matters. ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'Votera keeps it heard—and protected.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ── Title & Description ───────────────────────
                      if (_detail!.title.isNotEmpty) ...[
                        Text(
                          _detail!.title,
                          style: AppTypography.sectionHeading,
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (_detail!.description.isNotEmpty) ...[
                        Text(
                          _detail!.description,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // ── Question ──────────────────────────────────────
                      Text(
                        _detail!.question,
                        style: AppTypography.sectionHeading,
                      ),
                      if (_detail!.isAnonymous) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.visibility_off_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Anonymous poll',
                              style: AppTypography.captionSmall,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── Vote/Results section ─────────────────────────────
                      if (!showResults) ...[
                        Text(
                          _hasVoted ? 'Your vote' : 'Cast your vote',
                          style: AppTypography.label,
                        ),
                        const SizedBox(height: 12),
                        ..._detail!.options.map((option) {
                          final selected = _selectedOptionId == option.optionId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: (_isVoting || _hasVoted)
                                  ? null
                                  : () => setState(
                                      () => _selectedOptionId = option.optionId,
                                    ),
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.blue.withAlpha(15)
                                      : Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.blue
                                        : AppColors.metallicBorder,
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: selected
                                          ? AppColors.blue
                                          : AppColors.textMuted,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option.text,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: selected
                                              ? AppColors.blue
                                              : (_hasVoted
                                                    ? AppColors.textMuted
                                                    : Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface),
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (_hasVoted && selected) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.blue,
                                        size: 18,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        if (_hasVoted) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _isLoadingResults
                                  ? null
                                  : () {
                                      setState(() => _isLoadingResults = true);
                                      context.read<PollCubit>().loadResults(
                                        widget.pollId,
                                      );
                                    },
                              icon: _isLoadingResults
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.bar_chart_rounded),
                              label: const Text(
                                'View Results',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.blue,
                                side: const BorderSide(color: AppColors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'You have already voted on this poll',
                            style: AppTypography.captionSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  (_selectedOptionId == null || _isVoting)
                                  ? null
                                  : _confirmAndCastVote,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isVoting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Submit Vote',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ],

                      // If poll is expired, show results section and a message
                      if (_isExpired) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.lock_clock, color: AppColors.warning),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'This poll has expired. Voting is closed. Results are shown below.',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ── Results section ───────────────────────────────
                      if (_isLoadingResults) ...[
                        const SizedBox(height: 32),
                        const Center(child: CircularProgressIndicator()),
                      ] else if (showResults) ...[
                        Text('Results', style: AppTypography.label),
                        const SizedBox(height: 12),
                        ..._results.map((r) => _ResultBar(result: r)),
                      ],
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
}

class _ResultBar extends StatelessWidget {
  const _ResultBar({required this.result});
  final PollResultEntity result;

  @override
  Widget build(BuildContext context) {
    final pct = result.percentage.clamp(0.0, 100.0) / 100.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(result.text, style: AppTypography.bodySmall),
              ),
              const SizedBox(width: 8),
              Text(
                '${result.voteCount} votes',
                style: AppTypography.captionSmall,
              ),
              const SizedBox(width: 6),
              Text(
                '${result.percentage.toStringAsFixed(1)}%',
                style: AppTypography.captionSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppColors.metallicLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
