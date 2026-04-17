import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';

abstract interface class IWorkspaceRepository {
  Future<int> createWorkspace({
    required String name,
    required int workspaceTypeId,
    required bool isPublic,
    required bool autoPublicJoin,
  });

  Future<List<WorkspaceEntity>> getUserWorkspaces();

  Future<List<WorkspaceEntity>> getPublicWorkspaces({String? search});

  Future<List<WorkspaceSearchResultEntity>> searchWorkspaces({
    required int userId,
    String? search,
    int? workspaceTypeId,
    bool? isVerified,
    int page = 1,
    int pageSize = 20,
  });

  Future<WorkspaceEntity> getWorkspaceById(int workspaceId);

  Future<void> inviteMember({
    required int workspaceId,
    required String contact,
    required String contactType,
  });

  Future<void> joinWorkspace({required int workspaceId, String? inviteCode});

  Future<void> approveMember({
    required int workspaceId,
    required int memberUserId,
    required bool isApproved,
  });

  Future<List<WorkspaceMemberEntity>> getMembers(int workspaceId);

  Future<void> requestVerification({
    required int workspaceId,
    required String companyDomain,
  });

  Future<WorkspaceVerificationEntity> getVerificationStatus(int workspaceId);

  Future<List<WorkspaceTypeEntity>> getWorkspaceTypes();

  Future<List<WorkspaceInviteEntity>> getMemberInvites();

  Future<void> respondInvite({
    required int workspaceId,
    required int userId,
    required bool isAccepted,
  });
}
