import 'package:votera_app/features/user/domain/entities/user_profile_entity.dart';

class WorkspaceSummaryModel extends WorkspaceSummaryEntity {
  const WorkspaceSummaryModel({
    required super.workspaceId,
    required super.name,
    required super.role,
  });

  factory WorkspaceSummaryModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceSummaryModel(
      workspaceId: (json['workspaceId'] as num).toInt(),
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }
}

class UserStatsModel extends UserStatsEntity {
  const UserStatsModel({required super.votes, required super.polls});

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      votes: (json['votes'] as num).toInt(),
      polls: (json['polls'] as num).toInt(),
    );
  }
}

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.mobile,
    required super.profilePicture,
    required super.workspaces,
    required super.stats,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final workspaceList = (json['workspaces'] as List<dynamic>? ?? [])
        .map((w) => WorkspaceSummaryModel.fromJson(w as Map<String, dynamic>))
        .toList();

    return UserProfileModel(
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      profilePicture: json['profilePicture'] as String? ?? '',
      workspaces: workspaceList,
      stats: UserStatsModel.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
