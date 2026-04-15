class DashboardStatsEntity {
  const DashboardStatsEntity({
    required this.activePolls,
    required this.votesCast,
    required this.voters,
  });

  final int activePolls;
  final int votesCast;
  final int voters;
}
