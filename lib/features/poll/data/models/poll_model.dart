import '../../domain/entities/poll_entity.dart';

class PollSummaryModel extends PollSummaryEntity {
  const PollSummaryModel({
    required super.pollId,
    required super.question,
    required super.category,
    required super.workspaceName,
    required super.visibility,
    required super.expiryDate,
    required super.hasVoted,
    required super.createdAt,
  });

  factory PollSummaryModel.fromJson(Map<String, dynamic> json) {
    return PollSummaryModel(
      pollId: (json['pollId'] as num).toInt(),
      question: json['question'] as String? ?? '',
      category: json['category'] as String? ?? '',
      workspaceName: json['workspaceName'] as String? ?? '',
      visibility: json['visibility'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
      hasVoted: json['hasVoted'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class PollOptionModel extends PollOptionEntity {
  const PollOptionModel({required super.optionId, required super.text});

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      optionId: (json['optionId'] as num).toInt(),
      text: json['text'] as String? ?? '',
    );
  }
}

class VoteModel extends VoteEntity {
  const VoteModel({
    required super.pollId,
    required super.optionId,
    required super.userId,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      pollId: (json['pollId'] as num).toInt(),
      optionId: (json['optionId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
    );
  }
}

class PollDetailModel extends PollDetailEntity {
  const PollDetailModel({
    required super.pollId,
    required super.question,
    required super.isAnonymous,
    required super.options,
    super.title,
    super.description,
    super.workspaceName,
    super.votes,
    super.expiryDate,
  });

  factory PollDetailModel.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>? ?? [])
        .map((o) => PollOptionModel.fromJson(o as Map<String, dynamic>))
        .toList();
    final vts = (json['votes'] as List<dynamic>? ?? [])
        .map((v) => VoteModel.fromJson(v as Map<String, dynamic>))
        .toList();
    return PollDetailModel(
      pollId: (json['pollId'] as num).toInt(),
      question: json['question'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isAnonymous: json['isAnonymous'] as bool? ?? true,
      options: opts,
      workspaceName: json['workspaceName'] as String? ?? '',
      votes: vts,
      expiryDate: json['expiryDate'] as String? ?? '',
    );
  }
}

class PollResultModel extends PollResultEntity {
  const PollResultModel({
    required super.optionId,
    required super.text,
    required super.voteCount,
    required super.percentage,
  });

  factory PollResultModel.fromJson(Map<String, dynamic> json) {
    return PollResultModel(
      optionId: (json['optionId'] as num).toInt(),
      text: json['text'] as String? ?? '',
      voteCount: (json['voteCount'] as num? ?? 0).toInt(),
      percentage: (json['percentage'] as num? ?? 0).toDouble(),
    );
  }
}
