import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.activePolls,
    required super.votesCast,
    required super.voters,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      DashboardStatsModel(
        activePolls: (json['activePolls'] as num).toInt(),
        votesCast: (json['votesCast'] as num).toInt(),
        voters: (json['voters'] as num).toInt(),
      );
}
