import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/features/comment/domain/entities/comment_entity.dart';
import 'package:votera_app/features/comment/domain/repositories/icomment_repository.dart';

abstract class CommentState {
  const CommentState();
}

class CommentInitial extends CommentState {
  const CommentInitial();
}

class CommentLoading extends CommentState {
  const CommentLoading();
}

class CommentsLoaded extends CommentState {
  const CommentsLoaded(this.comments);

  final List<CommentEntity> comments;
}

class CommentActionSuccess extends CommentState {
  const CommentActionSuccess();
}

class CommentError extends CommentState {
  const CommentError(this.message);

  final String message;
}

class CommentCubit extends Cubit<CommentState> {
  CommentCubit() : super(const CommentInitial()) {
    _repository = sl<ICommentRepository>();
  }

  late final ICommentRepository _repository;

  Future<void> loadComments(int pollId) async {
    emit(const CommentLoading());
    try {
      final comments = await _repository.getComments(pollId);
      emit(CommentsLoaded(comments));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> addComment({
    required int pollId,
    required String comment,
  }) async {
    emit(const CommentLoading());
    try {
      await _repository.addComment(pollId: pollId, comment: comment);
      emit(const CommentActionSuccess());
      await loadComments(pollId);
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }
}
