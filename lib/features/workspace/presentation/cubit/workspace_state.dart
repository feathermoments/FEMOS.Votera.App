import 'package:votera_app/features/workspace/domain/entities/workspace_entity.dart';

abstract class WorkspaceState {
  const WorkspaceState();
}

class WorkspaceInitial extends WorkspaceState {
  const WorkspaceInitial();
}

class WorkspaceLoading extends WorkspaceState {
  const WorkspaceLoading();
}

class WorkspaceListLoaded extends WorkspaceState {
  const WorkspaceListLoaded(this.workspaces);

  final List<WorkspaceEntity> workspaces;
}

class PublicWorkspacesLoaded extends WorkspaceState {
  const PublicWorkspacesLoaded(this.workspaces);

  final List<WorkspaceEntity> workspaces;
}

class WorkspaceSearchResultsLoaded extends WorkspaceState {
  const WorkspaceSearchResultsLoaded(this.results);

  final List<WorkspaceSearchResultEntity> results;
}

class WorkspaceDetailLoaded extends WorkspaceState {
  const WorkspaceDetailLoaded(this.workspace);

  final WorkspaceEntity workspace;
}

class WorkspaceMembersLoaded extends WorkspaceState {
  const WorkspaceMembersLoaded(this.members);

  final List<WorkspaceMemberEntity> members;
}

class WorkspaceVerificationLoaded extends WorkspaceState {
  const WorkspaceVerificationLoaded(this.verification);

  final WorkspaceVerificationEntity verification;
}

class WorkspaceActionSuccess extends WorkspaceState {
  const WorkspaceActionSuccess(this.message);

  final String message;
}

class WorkspaceTypesLoaded extends WorkspaceState {
  const WorkspaceTypesLoaded(this.types);

  final List<WorkspaceTypeEntity> types;
}

class WorkspaceInvitesLoaded extends WorkspaceState {
  const WorkspaceInvitesLoaded(this.invites);

  final List<WorkspaceInviteEntity> invites;
}

class WorkspaceInviteLinksLoaded extends WorkspaceState {
  const WorkspaceInviteLinksLoaded(this.links);

  final List<WorkspaceInviteLinkEntity> links;
}

class WorkspaceInviteLinkCreated extends WorkspaceState {
  const WorkspaceInviteLinkCreated(this.link);

  final WorkspaceInviteLinkEntity link;
}

class WorkspaceInviteValidated extends WorkspaceState {
  const WorkspaceInviteValidated(this.data);

  final WorkspaceInviteValidationEntity data;
}

class WorkspaceError extends WorkspaceState {
  const WorkspaceError(this.message);

  final String message;
}
