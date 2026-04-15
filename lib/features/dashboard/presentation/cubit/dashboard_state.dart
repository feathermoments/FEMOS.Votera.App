import 'package:votera_app/features/dashboard/domain/entities/active_poll_entity.dart';
import 'package:votera_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';

abstract class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({required this.activePolls, required this.stats});

  final List<ActivePollEntity> activePolls;
  final DashboardStatsEntity stats;
}

class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;
}
