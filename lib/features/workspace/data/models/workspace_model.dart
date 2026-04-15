import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';

class WorkspaceModel extends WorkspaceEntity {
  const WorkspaceModel({
    required super.workspaceId,
    required super.name,
    required super.slug,
    required super.workspaceTypeId,
    required super.workspaceType,
    required super.isPublic,
    required super.isVerified,
    required super.role,
    required super.joinedOn,
    required super.memberCount,
    required super.pollCount,
    required super.createdBy,
    required super.createdOn,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      workspaceId: (json['workspaceId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      workspaceTypeId: (json['workspaceTypeId'] as num? ?? 0).toInt(),
      workspaceType: json['workspaceType'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      role: json['role'] as String? ?? '',
      joinedOn: json['joinedOn'] as String? ?? '',
      memberCount: (json['memberCount'] as num? ?? 0).toInt(),
      pollCount: (json['pollCount'] as num? ?? 0).toInt(),
      createdBy: (json['createdBy'] as num? ?? 0).toInt(),
      createdOn: json['createdOn'] as String? ?? '',
    );
  }
}

class WorkspaceMemberModel extends WorkspaceMemberEntity {
  const WorkspaceMemberModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.mobileNumber,
    required super.role,
    required super.status,
    required super.joinedOn,
    required super.isApproved,
    required super.invitedBy,
  });

  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberModel(
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      joinedOn: json['joinedOn'] as String? ?? '',
      isApproved: json['isApproved'] as bool? ?? false,
      invitedBy: json['invitedBy'] as String? ?? '',
    );
  }
}

class WorkspaceVerificationModel extends WorkspaceVerificationEntity {
  const WorkspaceVerificationModel({
    required super.workspaceId,
    required super.statusName,
    required super.isVerified,
    super.reviewedAt,
  });

  factory WorkspaceVerificationModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceVerificationModel(
      workspaceId: (json['workspaceId'] as num).toInt(),
      statusName: json['statusName'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      reviewedAt: json['reviewedAt'] as String?,
    );
  }
}

class WorkspaceInviteModel extends WorkspaceInviteEntity {
  const WorkspaceInviteModel({
    required super.workspaceId,
    required super.workspaceName,
    required super.workspaceTypeName,
    required super.invitedByUserId,
    required super.invitedByName,
    required super.invitedOn,
    required super.slug,
    required super.isPublic,
    required super.isVerified,
    required super.role,
  });

  factory WorkspaceInviteModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceInviteModel(
      workspaceId: (json['workspaceId'] as num).toInt(),
      workspaceName: json['workspaceName'] as String? ?? '',
      workspaceTypeName: json['workspaceTypeName'] as String? ?? '',
      invitedByUserId: (json['invitedByUserId'] as num? ?? 0).toInt(),
      invitedByName: json['invitedByName'] as String? ?? '',
      invitedOn: json['invitedOn'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      role: json['role'] as String? ?? '',
    );
  }
}

class WorkspaceTypeModel extends WorkspaceTypeEntity {
  const WorkspaceTypeModel({
    required super.workspaceTypeId,
    required super.name,
  });

  factory WorkspaceTypeModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceTypeModel(
      workspaceTypeId: (json['workspaceTypeId'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );
  }
}

class WorkspaceSearchResultModel extends WorkspaceSearchResultEntity {
  const WorkspaceSearchResultModel({
    required super.workspaceId,
    required super.name,
    required super.workspaceTypeName,
    required super.verificationStatusName,
    required super.isVerified,
    required super.memberCount,
  });

  factory WorkspaceSearchResultModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceSearchResultModel(
      workspaceId: (json['workspaceId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      workspaceTypeName: json['workspaceTypeName'] as String? ?? '',
      verificationStatusName: json['verificationStatusName'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      memberCount: (json['memberCount'] as num? ?? 0).toInt(),
    );
  }
}
