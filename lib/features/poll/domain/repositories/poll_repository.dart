import '../entities/poll_entity.dart';

abstract interface class PollRepository {
  Future<List<PollSummaryEntity>> getPolls(int userId);

  Future<PollDetailEntity> getPollDetail(int pollId);

  Future<int> createPoll({
    required int workspaceId,
    required int categoryId,
    required String question,
    required List<String> options,
    required String visibility,
    String? expiryDate,
    bool isAnonymous = true,
  });

  Future<void> castVote({required int pollId, required int optionId});

  Future<List<PollResultEntity>> getResults(int pollId);
}
