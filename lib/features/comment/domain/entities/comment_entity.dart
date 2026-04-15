class CommentEntity {
  const CommentEntity({
    required this.commentId,
    required this.user,
    required this.comment,
    required this.createdAt,
  });

  final int commentId;
  final String user;
  final String comment;
  final String createdAt;
}
