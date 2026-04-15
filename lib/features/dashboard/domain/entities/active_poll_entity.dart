class ActivePollEntity {
  const ActivePollEntity({
    required this.pollId,
    required this.question,
    required this.totalVotes,
    required this.daysLeft,
    required this.isVoted,
  });

  final int pollId;
  final String question;
  final int totalVotes;
  final int daysLeft;
  final bool isVoted;
}
