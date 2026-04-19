class WorkspaceEntity {
  const WorkspaceEntity({
    required this.workspaceId,
    required this.name,
    required this.slug,
    required this.workspaceTypeId,
    required this.workspaceType,
    required this.isPublic,
    required this.isVerified,
    required this.role,
    required this.joinedOn,
    required this.memberCount,
    required this.pollCount,
    required this.createdBy,
    required this.createdOn,
  });

  final int workspaceId;
  final String name;
  final String slug;
  final int workspaceTypeId;
  final String workspaceType;
  final bool isPublic;
  final bool isVerified;
  final String role;
  final String joinedOn;
  final int memberCount;
  final int pollCount;
  final int createdBy;
  final String createdOn;
}

class WorkspaceMemberEntity {
  const WorkspaceMemberEntity({
    required this.userId,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.role,
    required this.status,
    required this.joinedOn,
    required this.isApproved,
    required this.invitedBy,
    required this.isDeclined,
    required this.isRejected,
  });

  final int userId;
  final String name;
  final String email;
  final String mobileNumber;
  final String role;
  final String status;
  final String joinedOn;
  final bool isApproved;
  final String invitedBy;
  final bool isDeclined;
  final bool isRejected;
}

class WorkspaceVerificationEntity {
  const WorkspaceVerificationEntity({
    required this.workspaceId,
    required this.statusName,
    required this.isVerified,
    this.reviewedAt,
  });

  final int workspaceId;
  final String statusName;
  final bool isVerified;
  final String? reviewedAt;
}

class WorkspaceInviteEntity {
  const WorkspaceInviteEntity({
    required this.workspaceId,
    required this.workspaceName,
    required this.workspaceTypeName,
    required this.invitedByUserId,
    required this.invitedByName,
    required this.invitedOn,
    required this.slug,
    required this.isPublic,
    required this.isVerified,
    required this.role,
  });

  final int workspaceId;
  final String workspaceName;
  final String workspaceTypeName;
  final int invitedByUserId;
  final String invitedByName;
  final String invitedOn;
  final String slug;
  final bool isPublic;
  final bool isVerified;
  final String role;
}

class WorkspaceTypeEntity {
  const WorkspaceTypeEntity({
    required this.workspaceTypeId,
    required this.name,
  });

  final int workspaceTypeId;
  final String name;
}

class WorkspaceSearchResultEntity {
  const WorkspaceSearchResultEntity({
    required this.workspaceId,
    required this.name,
    required this.workspaceTypeName,
    required this.verificationStatusName,
    required this.isVerified,
    required this.memberCount,
  });

  final int workspaceId;
  final String name;
  final String workspaceTypeName;
  final String verificationStatusName;
  final bool isVerified;
  final int memberCount;
}

class WorkspaceInviteValidationEntity {
  const WorkspaceInviteValidationEntity({
    required this.isValid,
    required this.message,
    required this.inviteId,
    required this.workspaceId,
    required this.maxUsage,
    required this.usageCount,
    required this.expiryDate,
    required this.roleToAssign,
    required this.userId,
    required this.workspaceName,
    required this.workspaceLogo,
  });

  final bool isValid;
  final String message;
  final int inviteId;
  final int workspaceId;
  final int maxUsage;
  final int usageCount;
  final String expiryDate;
  final String roleToAssign;
  final int userId;
  final String workspaceName;
  final String workspaceLogo;
}

class WorkspaceInviteLinkEntity {
  const WorkspaceInviteLinkEntity({
    required this.inviteId,
    required this.inviteCode,
    required this.inviteLink,
    required this.status,
    required this.usageCount,
    required this.maxUsage,
    required this.remainingUsage,
    required this.expiryDate,
    required this.totalJoins,
  });

  final int inviteId;
  final String inviteCode;
  final String inviteLink;
  final String status;
  final int usageCount;
  final int maxUsage;
  final int remainingUsage;
  final String expiryDate;
  final int totalJoins;
}
