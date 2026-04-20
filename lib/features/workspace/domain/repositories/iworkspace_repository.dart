import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';

abstract interface class IWorkspaceRepository {
  Future<int> createWorkspace({
    required String name,
    required int workspaceTypeId,
    required bool isPublic,
    required bool autoPublicJoin,
  });

  Future<List<WorkspaceEntity>> getUserWorkspaces();

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

  Future<Map<String, dynamic>> removeMember({
    required int workspaceId,
    required int userId,
  });

  Future<void> exitWorkspace({required int workspaceId});

  Future<WorkspaceInviteLinkEntity> createInviteLink({
    required int workspaceId,
    required String expiryDate,
    required int maxUsage,
    required String roleToAssign,
  });

  Future<List<WorkspaceInviteLinkEntity>> getWorkspaceInviteLinks(
    int workspaceId,
  );

  Future<WorkspaceInviteValidationEntity> validateInvite(String inviteCode);

  Future<String> joinViaInvite({
    required String inviteCode,
    required int roleIdToAssign,
    // required String userIp,
    // required String deviceInfo,
  });
}
