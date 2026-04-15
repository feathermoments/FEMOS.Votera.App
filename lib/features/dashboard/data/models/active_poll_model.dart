import '../../domain/entities/active_poll_entity.dart';

class ActivePollModel extends ActivePollEntity {
  const ActivePollModel({
    required super.pollId,
    required super.question,
    required super.totalVotes,
    required super.daysLeft,
    required super.isVoted,
  });

  factory ActivePollModel.fromJson(Map<String, dynamic> json) =>
      ActivePollModel(
        pollId: (json['pollId'] as num).toInt(),
        question: json['question'] as String,
        totalVotes: (json['totalVotes'] as num).toInt(),
        daysLeft: (json['daysLeft'] as num).toInt(),
        isVoted: json['isVoted'] as bool? ?? false,
      );
}
