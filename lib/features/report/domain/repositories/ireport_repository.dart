abstract interface class IReportRepository {
  Future<void> reportWorkspace({
    required int workspaceId,
    required String reason,
    String? description,
  });
}
