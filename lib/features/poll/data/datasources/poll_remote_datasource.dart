import 'package:dio/dio.dart';
import 'package:votera_app/core/config/api_routes.dart';
import 'package:votera_app/core/network/api_client.dart';
import 'package:votera_app/core/network/api_exception.dart';

class PollRemoteDataSource {
  PollRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> fetchPolls() async {
    try {
      final data = await _client.get<List<dynamic>>(ApiRoutes.getPolls);
      return (data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<Map<String, dynamic>> fetchPollDetail(int pollId) async {
    try {
      final data = await _client.get<Map<String, dynamic>>(
        ApiRoutes.pollById(pollId),
      );
      return data ?? {};
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<int> createPoll(Map<String, dynamic> body) async {
    try {
      final data = await _client.post<Map<String, dynamic>>(
        ApiRoutes.createPoll,
        data: body,
      );
      return (data?['pollId'] as num? ?? 0).toInt();
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<void> castVote(int pollId, int optionId) async {
    try {
      await _client.post<Map<String, dynamic>>(
        ApiRoutes.castVote,
        data: {'pollId': pollId, 'optionId': optionId},
      );
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchResults(int pollId) async {
    try {
      final data = await _client.get<List<dynamic>>(
        ApiRoutes.pollResults(pollId),
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
        'Poll request failed';
    throw ApiException(
      message: msg,
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }
}
