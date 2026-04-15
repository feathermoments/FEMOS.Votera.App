class ReactionEntity {
  const ReactionEntity({
    required this.code,
    required this.emoji,
    required this.count,
  });

  final String code;
  final String emoji;
  final int count;
}
