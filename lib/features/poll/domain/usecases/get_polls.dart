import '../entities/poll_entity.dart';
import '../repositories/poll_repository.dart';

class GetPolls {
  const GetPolls(this.repository);

  final PollRepository repository;

  Future<List<PollSummaryEntity>> call(int userId) =>
      repository.getPolls(userId);
}
