import 'package:dio/dio.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/network/api_exception.dart';

class ReactionRemoteDataSource {
  ReactionRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> addReaction(int pollId, int reactionTypeId) async {
    try {
      await _client.post<Map<String, dynamic>>(
        ApiRoutes.addReaction,
        data: {'pollId': pollId, 'reactionTypeId': reactionTypeId},
      );
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchReactions(int pollId) async {
    try {
      final data = await _client.get<List<dynamic>>(
        ApiRoutes.reactionsByPoll(pollId),
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
        'Reaction request failed';
    throw ApiException(
      message: msg,
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }
}
