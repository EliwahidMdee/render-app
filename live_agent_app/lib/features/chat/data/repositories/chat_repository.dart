import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/message_model.dart';

class ChatRepository {
  final DioClient _dioClient;

  ChatRepository(this._dioClient);

  /// Helper method to execute request with retry logic for timeouts
  /// Returns a tuple: (result, errorMessage)
  Future<T> _executeWithRetry<T>({
    required Future<T> Function() request,
    required String operationName,
  }) async {
    try {
      // First attempt
      return await request();
    } on DioException catch (e) {
      // Check if it's a timeout error
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        AppLogger.warning('$operationName timed out, retrying once...');
        
        try {
          // Second attempt (automatic retry)
          return await request();
        } on DioException catch (retryError) {
          // Second attempt also failed
          if (retryError.type == DioExceptionType.connectionTimeout ||
              retryError.type == DioExceptionType.receiveTimeout ||
              retryError.type == DioExceptionType.sendTimeout) {
            AppLogger.error('$operationName failed after retry (timeout)', retryError);
            throw Exception('Connection timed out after retry. Please check your internet and try again.');
          } else {
            AppLogger.error('$operationName failed after retry', retryError);
            throw Exception('Failed to $operationName: ${retryError.response?.data?['message'] ?? retryError.message}');
          }
        } catch (e) {
          AppLogger.error('$operationName failed after retry', e);
          throw Exception('Failed to $operationName: $e');
        }
      } else {
        // Not a timeout error, throw immediately
        AppLogger.error('$operationName failed', e);
        throw Exception('Failed to $operationName: ${e.response?.data?['message'] ?? e.message}');
      }
    } catch (e) {
      AppLogger.error('Error during $operationName', e);
      throw Exception('Failed to $operationName: $e');
    }
  }

  Future<List<MessageModel>> getMessages(
    String sessionId, {
    bool markAsRead = true,
    int page = 1,
    int perPage = 50,
  }) async {
    return _executeWithRetry(
      operationName: 'fetch messages',
      request: () async {
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
      },
    );
  }

  Future<MessageModel> sendMessage(String sessionId, String messageText) async {
    return _executeWithRetry(
      operationName: 'send message',
      request: () async {
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
      },
    );
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
