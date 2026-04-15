import 'package:votera_app/features/comment/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.commentId,
    required super.user,
    required super.comment,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: (json['commentId'] as num).toInt(),
      user: json['user'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
