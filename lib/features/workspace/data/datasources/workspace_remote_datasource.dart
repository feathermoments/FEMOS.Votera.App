import 'package:dio/dio.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/network/api_exception.dart';

class WorkspaceRemoteDataSource {
  WorkspaceRemoteDataSource(this._client);

  final ApiClient _client;

  Future<int> createWorkspace(Map<String, dynamic> body) async {
    try {
      final data = await _client.post<Map<String, dynamic>>(
        ApiRoutes.createWorkspace,
        data: body,
      );
      return (data?['workspaceId'] as num? ?? 0).toInt();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUserWorkspaces() async {
    try {
      final data = await _client.get<List<dynamic>>(ApiRoutes.userWorkspaces);
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<List<Map<String, dynamic>>> getPublicWorkspaces({
    String? search,
  }) async {
    try {
      final data = await _client.get<List<dynamic>>(
        ApiRoutes.publicWorkspaces,
        queryParameters: search != null && search.isNotEmpty
            ? {'search': search}
            : null,
      );
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<List<Map<String, dynamic>>> searchWorkspaces(
    Map<String, dynamic> body,
  ) async {
    try {
      final data = await _client.post<List<dynamic>>(
        ApiRoutes.workspaceSearch,
        data: body,
      );
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<Map<String, dynamic>> getWorkspaceById(int id) async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiRoutes.workspaceById(id),
      );
      return data ?? {};
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<void> inviteMember(Map<String, dynamic> body) async {
    try {
      await _client.post<Map<String, dynamic>>(
        ApiRoutes.inviteMember,
        data: body,
      );
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<void> joinWorkspace(Map<String, dynamic> body) async {
    try {
      await _client.post<Map<String, dynamic>>(
        ApiRoutes.joinWorkspace,
        data: body,
      );
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<void> approveMember(Map<String, dynamic> body) async {
    try {
      await _client.post<Map<String, dynamic>>(
        ApiRoutes.approveMember,
        data: body,
      );
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMembers(int workspaceId) async {
    try {
      final data = await _client.get<List<dynamic>>(
        ApiRoutes.workspaceMembers(workspaceId),
      );
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<void> requestVerification(Map<String, dynamic> body) async {
    try {
      await _client.post<Map<String, dynamic>>(
        ApiRoutes.requestVerification,
        data: body,
      );
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<Map<String, dynamic>> getVerificationStatus(int workspaceId) async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiRoutes.verificationStatus(workspaceId),
      );
      return data ?? {};
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<List<Map<String, dynamic>>> getWorkspaceTypes() async {
    try {
      final data = await _client.get<List<dynamic>>(ApiRoutes.workspaceTypes);
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMemberInvites() async {
    try {
      final data = await _client.get<List<dynamic>>(ApiRoutes.memberInvites);
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<void> respondInvite(Map<String, dynamic> body) async {
    try {
      await _client.post<Map<String, dynamic>>(
        ApiRoutes.respondInvite,
        data: body,
      );
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<Map<String, dynamic>> createInviteLink(
    Map<String, dynamic> body,
  ) async {
    try {
      final data = await _client.post<Map<String, dynamic>>(
        ApiRoutes.createInviteLink,
        data: body,
      );
      return data ?? {};
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<List<Map<String, dynamic>>> getWorkspaceInviteLinks(
    int workspaceId,
  ) async {
    try {
      final data = await _client.get<List<dynamic>>(
        ApiRoutes.workspaceInviteLinks(workspaceId),
      );
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Never _throw(DioException e) {
    final msg =
        (e.response?.data as Map?)?['message'] as String? ??
        e.message ??
        'Workspace request failed';
    throw ApiException(
      message: msg,
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }
}
