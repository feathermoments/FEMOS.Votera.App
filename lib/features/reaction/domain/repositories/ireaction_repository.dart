import 'package:votera_app/features/reaction/domain/entities/reaction_entity.dart';

abstract interface class IReactionRepository {
  Future<void> addReaction({required int pollId, required int reactionTypeId});

  Future<List<ReactionEntity>> getReactions(int pollId);
}
