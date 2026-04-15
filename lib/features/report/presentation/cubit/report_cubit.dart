import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/features/report/domain/repositories/ireport_repository.dart';

abstract class ReportState {
  const ReportState();
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportSuccess extends ReportState {
  const ReportSuccess();
}

class ReportError extends ReportState {
  const ReportError(this.message);

  final String message;
}

class ReportCubit extends Cubit<ReportState> {
  ReportCubit() : super(const ReportInitial()) {
    _repository = sl<IReportRepository>();
  }

  late final IReportRepository _repository;

  Future<void> reportWorkspace({
    required int workspaceId,
    required String reason,
    String? description,
  }) async {
    emit(const ReportLoading());
    try {
      await _repository.reportWorkspace(
        workspaceId: workspaceId,
        reason: reason,
        description: description,
      );
      emit(const ReportSuccess());
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
