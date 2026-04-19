import '../../domain/entities/poll_entity.dart';
import '../../domain/repositories/poll_repository.dart';
import '../datasources/poll_remote_datasource.dart';
import '../models/poll_model.dart';

class PollRepositoryImpl implements PollRepository {
  PollRepositoryImpl(this.remote);

  final PollRemoteDataSource remote;

  @override
  Future<List<PollSummaryEntity>> getPolls(int userId) async {
    final data = await remote.fetchPolls();
    return data.map(PollSummaryModel.fromJson).toList();
  }

  @override
  Future<PollDetailEntity> getPollDetail(int pollId) async {
    final json = await remote.fetchPollDetail(pollId);
    return PollDetailModel.fromJson(json);
  }

  @override
  Future<int> createPoll({
    required int workspaceId,
    required int categoryId,
    required String question,
    required List<String> options,
    required String visibility,
    String? title,
    String? description,
    String? expiryDate,
    bool isAnonymous = true,
  }) {
    final body = <String, dynamic>{
      'workspaceId': workspaceId,
      'categoryId': categoryId,
      'question': question,
      'options': options,
      'visibility': visibility,
      'isAnonymous': isAnonymous,
    };
    if (title != null && title.isNotEmpty) body['title'] = title;
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    if (expiryDate != null) body['expiryDate'] = expiryDate;
    return remote.createPoll(body);
  }

  @override
  Future<void> castVote({required int pollId, required int optionId}) =>
      remote.castVote(pollId, optionId);

  @override
  Future<List<PollResultEntity>> getResults(int pollId) async {
    final data = await remote.fetchResults(pollId);
    return data.map(PollResultModel.fromJson).toList();
  }
}
