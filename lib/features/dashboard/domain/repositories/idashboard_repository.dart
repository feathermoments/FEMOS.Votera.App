import 'package:votera_app/features/dashboard/domain/entities/active_poll_entity.dart';
import 'package:votera_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';

abstract interface class IDashboardRepository {
  Future<List<ActivePollEntity>> getActivePolls();
  Future<DashboardStatsEntity> getDashboardStats();
}
