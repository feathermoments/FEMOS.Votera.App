import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/core/storage/secure_storage.dart';
import 'package:votera_app/features/workspace/domain/repositories/iworkspace_repository.dart';
import 'package:votera_app/features/workspace/presentation/cubit/workspace_state.dart';

class WorkspaceCubit extends Cubit<WorkspaceState> {
  WorkspaceCubit() : super(const WorkspaceInitial()) {
    _repository = sl<IWorkspaceRepository>();
  }

  late final IWorkspaceRepository _repository;

  Future<void> loadUserWorkspaces() async {
    emit(const WorkspaceLoading());
    try {
      final workspaces = await _repository.getUserWorkspaces();
      emit(WorkspaceListLoaded(workspaces));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> loadWorkspace(int workspaceId) async {
    emit(const WorkspaceLoading());
    try {
      final workspace = await _repository.getWorkspaceById(workspaceId);
      emit(WorkspaceDetailLoaded(workspace));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> createWorkspace({
    required String name,
    required int workspaceTypeId,
    required bool isPublic,
    required bool autoPublicJoin,
  }) async {
    emit(const WorkspaceLoading());
    try {
      await _repository.createWorkspace(
        name: name,
        workspaceTypeId: workspaceTypeId,
        isPublic: isPublic,
        autoPublicJoin: autoPublicJoin,
      );
      emit(const WorkspaceActionSuccess('Workspace created successfully'));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> inviteMember({
    required int workspaceId,
    required String contact,
    required String contactType,
  }) async {
    emit(const WorkspaceLoading());
    try {
      await _repository.inviteMember(
        workspaceId: workspaceId,
        contact: contact,
        contactType: contactType,
      );
      emit(const WorkspaceActionSuccess('Invitation sent successfully'));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> joinWorkspace({
    required int workspaceId,
    String? inviteCode,
  }) async {
    emit(const WorkspaceLoading());
    try {
      await _repository.joinWorkspace(
        workspaceId: workspaceId,
        inviteCode: inviteCode,
      );
      emit(const WorkspaceActionSuccess('Request sent for approval'));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> approveMember({
    required int workspaceId,
    required int memberUserId,
    required bool isApproved,
  }) async {
    emit(const WorkspaceLoading());
    try {
      await _repository.approveMember(
        workspaceId: workspaceId,
        memberUserId: memberUserId,
        isApproved: isApproved,
      );
      final msg = isApproved ? 'Member approved' : 'Member rejected';
      emit(WorkspaceActionSuccess(msg));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> loadMembers(int workspaceId) async {
    emit(const WorkspaceLoading());
    try {
      final members = await _repository.getMembers(workspaceId);
      emit(WorkspaceMembersLoaded(members));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> requestVerification({
    required int workspaceId,
    required String companyDomain,
  }) async {
    emit(const WorkspaceLoading());
    try {
      await _repository.requestVerification(
        workspaceId: workspaceId,
        companyDomain: companyDomain,
      );
      emit(const WorkspaceActionSuccess('Verification request submitted'));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> loadVerificationStatus(int workspaceId) async {
    emit(const WorkspaceLoading());
    try {
      final status = await _repository.getVerificationStatus(workspaceId);
      emit(WorkspaceVerificationLoaded(status));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> loadWorkspaceTypes() async {
    emit(const WorkspaceLoading());
    try {
      final types = await _repository.getWorkspaceTypes();
      emit(WorkspaceTypesLoaded(types));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> loadInvites() async {
    emit(const WorkspaceLoading());
    try {
      final invites = await _repository.getMemberInvites();
      emit(WorkspaceInvitesLoaded(invites));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> respondToInvite({
    required int workspaceId,
    required int userId,
    required bool isAccepted,
  }) async {
    emit(const WorkspaceLoading());
    try {
      await _repository.respondInvite(
        workspaceId: workspaceId,
        userId: userId,
        isAccepted: isAccepted,
      );
      final msg = isAccepted ? 'Invite accepted' : 'Invite declined';
      emit(WorkspaceActionSuccess(msg));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> removeMember({
    required int workspaceId,
    required int userId,
  }) async {
    emit(const WorkspaceLoading());
    try {
      final res = await _repository.removeMember(
        workspaceId: workspaceId,
        userId: userId,
      );
      final status = (res['status'] as String?)?.toLowerCase() ?? 'success';
      final message =
          res['message'] as String? ?? 'Member removed successfully';
      if (status == 'failed' || status == 'fail' || status == 'error') {
        emit(WorkspaceError(message));
      } else {
        emit(WorkspaceActionSuccess(message));
      }
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> exitWorkspace({required int workspaceId}) async {
    emit(const WorkspaceLoading());
    try {
      await _repository.exitWorkspace(workspaceId: workspaceId);
      emit(const WorkspaceExitSuccess());
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> searchWorkspaces({
    String? search,
    int? workspaceTypeId,
    bool? isVerified,
    int page = 1,
    int pageSize = 20,
  }) async {
    emit(const WorkspaceLoading());
    try {
      final userId = await sl<SecureStorageService>().getUserId() ?? 0;
      final results = await _repository.searchWorkspaces(
        userId: userId,
        search: search,
        workspaceTypeId: workspaceTypeId,
        isVerified: isVerified,
        page: page,
        pageSize: pageSize,
      );
      emit(WorkspaceSearchResultsLoaded(results));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> requestJoinWorkspace(int workspaceId) async {
    emit(const WorkspaceLoading());
    try {
      await _repository.joinWorkspace(workspaceId: workspaceId);
      emit(const WorkspaceActionSuccess('Join request sent successfully'));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> loadWorkspaceInviteLinks(int workspaceId) async {
    emit(const WorkspaceLoading());
    try {
      final links = await _repository.getWorkspaceInviteLinks(workspaceId);
      emit(WorkspaceInviteLinksLoaded(links));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> createInviteLink({
    required int workspaceId,
    required String expiryDate,
    required int maxUsage,
    required String roleToAssign,
  }) async {
    emit(const WorkspaceLoading());
    try {
      final link = await _repository.createInviteLink(
        workspaceId: workspaceId,
        expiryDate: expiryDate,
        maxUsage: maxUsage,
        roleToAssign: roleToAssign,
      );
      emit(WorkspaceInviteLinkCreated(link));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> validateInviteCode(String inviteCode) async {
    emit(const WorkspaceLoading());
    try {
      final data = await _repository.validateInvite(inviteCode);
      emit(WorkspaceInviteValidated(data));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> joinViaInviteCode(String inviteCode) async {
    emit(const WorkspaceLoading());
    try {
      final deviceInfo = await _collectDeviceInfo();
      final message = await _repository.joinViaInvite(
        inviteCode: inviteCode,
        roleIdToAssign: 3,
      );
      emit(WorkspaceActionSuccess(message));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<String> _collectDeviceInfo() async {
    try {
      final plugin = DeviceInfoPlugin();
      if (kIsWeb) {
        final info = await plugin.webBrowserInfo;
        return info.userAgent ?? 'Web';
      } else if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        return '${info.manufacturer} ${info.model} (Android ${info.version.release})';
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return '${info.name} ${info.systemVersion}';
      } else {
        return Platform.operatingSystem;
      }
    } catch (_) {
      return 'Unknown';
    }
  }
}
