import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/session_model.dart';

class SessionRepository {
  final DioClient _dioClient;

  SessionRepository(this._dioClient);

  Future<List<SessionModel>> getSessions({
    String? status,
    int page = 1,
    int perPage = 20,
    bool assignedToMe = false,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/live-agent/sessions',
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'per_page': perPage,
          if (assignedToMe) 'assigned_to_me': true,
        },
      );

      final sessionsList = response.data['sessions'] as List? ?? [];
      final sessions = sessionsList
          .map((json) => SessionModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${sessions.length} sessions');
      return sessions;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch sessions', e);
      throw Exception('Failed to fetch sessions: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      AppLogger.error('Error fetching sessions', e);
      throw Exception('Failed to fetch sessions: $e');
    }
  }

  Future<SessionModel> getSessionDetails(String sessionId) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/live-agent/sessions/$sessionId',
      );

      final session = SessionModel.fromJson(response.data as Map<String, dynamic>);
      AppLogger.info('Fetched session details for: $sessionId');
      return session;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch session details', e);
      throw Exception('Failed to fetch session details: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      AppLogger.error('Error fetching session details', e);
      throw Exception('Failed to fetch session details: $e');
    }
  }

  Future<void> assignSession(String sessionId, String agentId, String agentName) async {
    try {
      await _dioClient.dio.put(
        '/api/v1/live-agent/sessions/$sessionId/status',
        data: {
          'status': 'active',
          'assigned_agent_id': agentId,
          'assigned_agent_name': agentName,
        },
      );
      AppLogger.info('Assigned session $sessionId to $agentName');
    } on DioException catch (e) {
      AppLogger.error('Failed to assign session', e);
      throw Exception('Failed to assign session: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      AppLogger.error('Error assigning session', e);
      throw Exception('Failed to assign session: $e');
    }
  }

  Future<void> closeSession(String sessionId) async {
    try {
      await _dioClient.dio.put(
        '/api/v1/live-agent/sessions/$sessionId/status',
        data: {'status': 'resolved'},
      );
      AppLogger.info('Closed session: $sessionId');
    } on DioException catch (e) {
      AppLogger.error('Failed to close session', e);
      throw Exception('Failed to close session: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      AppLogger.error('Error closing session', e);
      throw Exception('Failed to close session: $e');
    }
  }

  Future<void> updateSessionStatus(String sessionId, String status) async {
    try {
      await _dioClient.dio.put(
        '/api/v1/live-agent/sessions/$sessionId/status',
        data: {'status': status},
      );
      AppLogger.info('Updated session $sessionId status to $status');
    } on DioException catch (e) {
      AppLogger.error('Failed to update session status', e);
      throw Exception('Failed to update session status: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      AppLogger.error('Error updating session status', e);
      throw Exception('Failed to update session status: $e');
    }
  }
}
