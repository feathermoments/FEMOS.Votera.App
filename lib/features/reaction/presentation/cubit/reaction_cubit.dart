import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/features/reaction/domain/entities/reaction_entity.dart';
import 'package:votera_app/features/reaction/domain/repositories/ireaction_repository.dart';

abstract class ReactionState {
  const ReactionState();
}

class ReactionInitial extends ReactionState {
  const ReactionInitial();
}

class ReactionLoading extends ReactionState {
  const ReactionLoading();
}

class ReactionsLoaded extends ReactionState {
  const ReactionsLoaded(this.reactions);

  final List<ReactionEntity> reactions;
}

class ReactionActionSuccess extends ReactionState {
  const ReactionActionSuccess();
}

class ReactionError extends ReactionState {
  const ReactionError(this.message);

  final String message;
}

class ReactionCubit extends Cubit<ReactionState> {
  ReactionCubit() : super(const ReactionInitial()) {
    _repository = sl<IReactionRepository>();
  }

  late final IReactionRepository _repository;

  Future<void> loadReactions(int pollId) async {
    emit(const ReactionLoading());
    try {
      final reactions = await _repository.getReactions(pollId);
      emit(ReactionsLoaded(reactions));
    } catch (e) {
      emit(ReactionError(e.toString()));
    }
  }

  Future<void> react({required int pollId, required int reactionTypeId}) async {
    try {
      await _repository.addReaction(
        pollId: pollId,
        reactionTypeId: reactionTypeId,
      );
      emit(const ReactionActionSuccess());
      await loadReactions(pollId);
    } catch (e) {
      emit(ReactionError(e.toString()));
    }
  }
}
