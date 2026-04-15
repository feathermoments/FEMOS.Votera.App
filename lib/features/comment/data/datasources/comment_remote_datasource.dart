import 'package:dio/dio.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/network/api_exception.dart';

class CommentRemoteDataSource {
  CommentRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> addComment(int pollId, String comment) async {
    try {
      await _client.post<Map<String, dynamic>>(
        ApiRoutes.addComment,
        data: {'pollId': pollId, 'comment': comment},
      );
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments(int pollId) async {
    try {
      final data = await _client.get<List<dynamic>>(
        ApiRoutes.commentsByPoll(pollId),
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
        'Comment request failed';
    throw ApiException(
      message: msg,
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }
}
