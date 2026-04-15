import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/features/dashboard/domain/repositories/idashboard_repository.dart';
import 'package:votera_app/features/dashboard/presentation/cubit/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardInitial());

  final IDashboardRepository _repo = sl<IDashboardRepository>();

  Future<void> load() async {
    try {
      final polls = await _repo.getActivePolls();
      final stats = await _repo.getDashboardStats();
      emit(DashboardLoaded(activePolls: polls, stats: stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
