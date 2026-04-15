class WorkspaceSummaryEntity {
  const WorkspaceSummaryEntity({
    required this.workspaceId,
    required this.name,
    required this.role,
  });

  final int workspaceId;
  final String name;
  final String role;
}

class UserStatsEntity {
  const UserStatsEntity({required this.votes, required this.polls});

  final int votes;
  final int polls;
}

class UserProfileEntity {
  const UserProfileEntity({
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.profilePicture,
    required this.workspaces,
    required this.stats,
  });

  final int userId;
  final String name;
  final String email;
  final String mobile;
  final String profilePicture;
  final List<WorkspaceSummaryEntity> workspaces;
  final UserStatsEntity stats;
}
