import 'package:votera_app/features/reaction/data/datasources/reaction_remote_datasource.dart';
import 'package:votera_app/features/reaction/data/models/reaction_model.dart';
import 'package:votera_app/features/reaction/domain/entities/reaction_entity.dart';
import 'package:votera_app/features/reaction/domain/repositories/ireaction_repository.dart';

class ReactionRepositoryImpl implements IReactionRepository {
  ReactionRepositoryImpl(this._dataSource);

  final ReactionRemoteDataSource _dataSource;

  @override
  Future<void> addReaction({
    required int pollId,
    required int reactionTypeId,
  }) => _dataSource.addReaction(pollId, reactionTypeId);

  @override
  Future<List<ReactionEntity>> getReactions(int pollId) async {
    final list = await _dataSource.fetchReactions(pollId);
    return list.map(ReactionModel.fromJson).toList();
  }
}
