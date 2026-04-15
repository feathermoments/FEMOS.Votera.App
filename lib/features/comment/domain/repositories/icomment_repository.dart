import 'package:votera_app/features/comment/domain/entities/comment_entity.dart';

abstract interface class ICommentRepository {
  Future<void> addComment({required int pollId, required String comment});

  Future<List<CommentEntity>> getComments(int pollId);
}
