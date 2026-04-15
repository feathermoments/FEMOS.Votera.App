import 'package:votera_app/features/report/data/datasources/report_remote_datasource.dart';
import 'package:votera_app/features/report/domain/repositories/ireport_repository.dart';

class ReportRepositoryImpl implements IReportRepository {
  ReportRepositoryImpl(this._dataSource);

  final ReportRemoteDataSource _dataSource;

  @override
  Future<void> reportWorkspace({
    required int workspaceId,
    required String reason,
    String? description,
  }) {
    final body = <String, dynamic>{
      'workspaceId': workspaceId,
      'reason': reason,
    };
    if (description != null) body['description'] = description;
    return _dataSource.reportWorkspace(body);
  }
}
