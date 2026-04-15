import 'package:votera_app/features/comment/data/datasources/comment_remote_datasource.dart';
import 'package:votera_app/features/comment/data/models/comment_model.dart';
import 'package:votera_app/features/comment/domain/entities/comment_entity.dart';
import 'package:votera_app/features/comment/domain/repositories/icomment_repository.dart';

class CommentRepositoryImpl implements ICommentRepository {
  CommentRepositoryImpl(this._dataSource);

  final CommentRemoteDataSource _dataSource;

  @override
  Future<void> addComment({required int pollId, required String comment}) =>
      _dataSource.addComment(pollId, comment);

  @override
  Future<List<CommentEntity>> getComments(int pollId) async {
    final list = await _dataSource.fetchComments(pollId);
    return list.map(CommentModel.fromJson).toList();
  }
}
