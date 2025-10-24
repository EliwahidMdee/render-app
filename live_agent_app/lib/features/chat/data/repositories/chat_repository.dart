import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/message_model.dart';

class ChatRepository {
  final DioClient _dioClient;

  ChatRepository(this._dioClient);

  Future<List<MessageModel>> getMessages(
    String sessionId, {
    bool markAsRead = true,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/live-agent/messages/$sessionId',
        queryParameters: {
          'mark_as_read': markAsRead,
          'page': page,
          'per_page': perPage,
        },
      );

      final messagesList = response.data['messages'] as List? ?? [];
      final messages = messagesList
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${messages.length} messages for session $sessionId');
      return messages;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch messages', e);
      throw Exception('Failed to fetch messages: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      AppLogger.error('Error fetching messages', e);
      throw Exception('Failed to fetch messages: $e');
    }
  }

  Future<MessageModel> sendMessage(String sessionId, String messageText) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/live-agent/messages',
        data: {
          'session_id': sessionId,
          'message_text': messageText,
          'sender_type': 'agent',
        },
      );

      final message = MessageModel.fromJson(response.data as Map<String, dynamic>);
      AppLogger.info('Sent message to session $sessionId');
      return message;
    } on DioException catch (e) {
      AppLogger.error('Failed to send message', e);
      throw Exception('Failed to send message: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      AppLogger.error('Error sending message', e);
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> markMessagesAsRead(String sessionId) async {
    try {
      await _dioClient.dio.get(
        '/api/v1/live-agent/messages/$sessionId',
        queryParameters: {'mark_as_read': true},
      );
      AppLogger.info('Marked messages as read for session $sessionId');
    } catch (e) {
      AppLogger.warning('Failed to mark messages as read: $e');
    }
  }
}
