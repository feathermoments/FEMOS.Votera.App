/// Summary entity returned by GET /poll/list/{userId}
class PollSummaryEntity {
  const PollSummaryEntity({
    required this.pollId,
    required this.question,
    required this.category,
    required this.workspaceName,
    required this.visibility,
    required this.expiryDate,
    required this.hasVoted,
    required this.createdAt,
  });

  final int pollId;
  final String question;
  final String category;
  final String workspaceName;
  final String visibility;
  final String expiryDate;
  final bool hasVoted;
  final String createdAt;
}

/// A single vote record returned inside poll detail.
class VoteEntity {
  const VoteEntity({
    required this.pollId,
    required this.optionId,
    required this.userId,
  });

  final int pollId;
  final int optionId;
  final int userId;
}

/// Option inside a poll detail.
class PollOptionEntity {
  const PollOptionEntity({required this.optionId, required this.text});

  final int optionId;
  final String text;
}

/// Full detail entity returned by GET /poll/{pollId}
class PollDetailEntity {
  const PollDetailEntity({
    required this.pollId,
    required this.question,
    required this.isAnonymous,
    required this.options,
    this.title = '',
    this.description = '',
    this.workspaceName = '',
    this.votes = const [],
  });

  final int pollId;
  final String question;
  final String title;
  final String description;
  final bool isAnonymous;
  final List<PollOptionEntity> options;
  final String workspaceName;
  final List<VoteEntity> votes;
}

/// Result item returned by GET /poll/results/{pollId}
class PollResultEntity {
  const PollResultEntity({
    required this.optionId,
    required this.text,
    required this.voteCount,
    required this.percentage,
  });

  final int optionId;
  final String text;
  final int voteCount;
  final double percentage;
}

// Keep legacy alias for any existing code that imports PollEntity
typedef PollEntity = PollSummaryEntity;
