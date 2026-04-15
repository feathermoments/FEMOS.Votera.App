import 'package:votera_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:votera_app/features/dashboard/data/models/active_poll_model.dart';
import 'package:votera_app/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:votera_app/features/dashboard/domain/entities/active_poll_entity.dart';
import 'package:votera_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:votera_app/features/dashboard/domain/repositories/idashboard_repository.dart';

class DashboardRepositoryImpl implements IDashboardRepository {
  DashboardRepositoryImpl(this._remote);

  final DashboardRemoteDataSource _remote;

  @override
  Future<List<ActivePollEntity>> getActivePolls() async {
    final data = await _remote.fetchActivePolls();
    return data.map(ActivePollModel.fromJson).toList();
  }

  @override
  Future<DashboardStatsEntity> getDashboardStats() async {
    final data = await _remote.fetchDashboardStats();
    return DashboardStatsModel.fromJson(data);
  }
}
