import 'package:votera_app/features/workspace/data/datasources/workspace_remote_datasource.dart';
import 'package:votera_app/features/workspace/data/models/workspace_model.dart';
import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';
import 'package:votera_app/features/workspace/domain/repositories/iworkspace_repository.dart';

class WorkspaceRepositoryImpl implements IWorkspaceRepository {
  WorkspaceRepositoryImpl(this._dataSource);

  final WorkspaceRemoteDataSource _dataSource;

  @override
  Future<int> createWorkspace({
    required String name,
    required int workspaceTypeId,
    required bool isPublic,
    required bool autoPublicJoin,
  }) {
    return _dataSource.createWorkspace({
      'name': name,
      'workspaceTypeId': workspaceTypeId,
      'isPublic': isPublic,
      'autoPublicJoin': autoPublicJoin,
    });
  }

  @override
  Future<List<WorkspaceEntity>> getUserWorkspaces() async {
    final list = await _dataSource.getUserWorkspaces();
    return list.map(WorkspaceModel.fromJson).toList();
  }

  @override
  Future<List<WorkspaceSearchResultEntity>> searchWorkspaces({
    required int userId,
    String? search,
    int? workspaceTypeId,
    bool? isVerified,
    int page = 1,
    int pageSize = 20,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'page': page,
      'pageSize': pageSize,
    };
    if (search != null && search.isNotEmpty) body['search'] = search;
    if (workspaceTypeId != null) body['workspaceTypeId'] = workspaceTypeId;
    if (isVerified != null) body['isVerified'] = isVerified;
    final list = await _dataSource.searchWorkspaces(body);
    return list.map(WorkspaceSearchResultModel.fromJson).toList();
  }

  @override
  Future<WorkspaceEntity> getWorkspaceById(int workspaceId) async {
    final json = await _dataSource.getWorkspaceById(workspaceId);
    return WorkspaceModel.fromJson(json);
  }

  @override
  Future<void> inviteMember({
    required int workspaceId,
    required String contact,
    required String contactType,
  }) {
    return _dataSource.inviteMember({
      'workspaceId': workspaceId,
      'contact': contact,
      'contactType': contactType,
    });
  }

  @override
  Future<void> joinWorkspace({required int workspaceId, String? inviteCode}) {
    final body = <String, dynamic>{'workspaceId': workspaceId};
    if (inviteCode != null) body['inviteCode'] = inviteCode;
    return _dataSource.joinWorkspace(body);
  }

  @override
  Future<void> approveMember({
    required int workspaceId,
    required int memberUserId,
    required bool isApproved,
  }) {
    return _dataSource.approveMember({
      'workspaceId': workspaceId,
      'memberUserId': memberUserId,
      'isApproved': isApproved,
    });
  }

  @override
  Future<List<WorkspaceMemberEntity>> getMembers(int workspaceId) async {
    final list = await _dataSource.getMembers(workspaceId);
    return list.map(WorkspaceMemberModel.fromJson).toList();
  }

  @override
  Future<void> requestVerification({
    required int workspaceId,
    required String companyDomain,
  }) {
    return _dataSource.requestVerification({
      'workspaceId': workspaceId,
      'companyDomain': companyDomain,
    });
  }

  @override
  Future<WorkspaceVerificationEntity> getVerificationStatus(
    int workspaceId,
  ) async {
    final json = await _dataSource.getVerificationStatus(workspaceId);
    return WorkspaceVerificationModel.fromJson(json);
  }

  @override
  Future<List<WorkspaceTypeEntity>> getWorkspaceTypes() async {
    final list = await _dataSource.getWorkspaceTypes();
    return list.map(WorkspaceTypeModel.fromJson).toList();
  }

  @override
  Future<List<WorkspaceInviteEntity>> getMemberInvites() async {
    final list = await _dataSource.getMemberInvites();
    return list.map(WorkspaceInviteModel.fromJson).toList();
  }

  @override
  Future<void> respondInvite({
    required int workspaceId,
    required int userId,
    required bool isAccepted,
  }) {
    return _dataSource.respondInvite({
      'workspaceId': workspaceId,
      'userId': userId,
      'isAccepted': isAccepted,
    });
  }

  @override
  Future<WorkspaceInviteLinkEntity> createInviteLink({
    required int workspaceId,
    required String expiryDate,
    required int maxUsage,
    required String roleToAssign,
  }) async {
    final json = await _dataSource.createInviteLink({
      'workspaceId': workspaceId,
      'expiryDate': expiryDate,
      'maxUsage': maxUsage,
      'roleToAssign': roleToAssign,
    });
    return WorkspaceInviteLinkModel.fromJson(json);
  }

  @override
  Future<List<WorkspaceInviteLinkEntity>> getWorkspaceInviteLinks(
    int workspaceId,
  ) async {
    final list = await _dataSource.getWorkspaceInviteLinks(workspaceId);
    return list.map(WorkspaceInviteLinkModel.fromJson).toList();
  }

  @override
  Future<WorkspaceInviteValidationEntity> validateInvite(
    String inviteCode,
  ) async {
    final json = await _dataSource.validateInvite(inviteCode);
    return WorkspaceInviteValidationModel.fromJson(json);
  }

  @override
  Future<String> joinViaInvite({
    required String inviteCode,
    required int roleIdToAssign,
    // required String userIp,
    // required String deviceInfo,
  }) {
    return _dataSource.joinViaInvite(
      inviteCode: inviteCode,
      roleIdToAssign: roleIdToAssign,
      // userIp: userIp,
      // deviceInfo: deviceInfo,
    );
  }
}
