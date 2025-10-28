import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';

// Chat Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatRepository(dioClient);
});

// Chat State Provider
class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final String sessionId;

  ChatNotifier(this._chatRepository, this.sessionId) : super(ChatState()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _chatRepository.getMessages(sessionId);
      state = state.copyWith(
        messages: messages.reversed.toList(), // Reverse for chat UI
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    state = state.copyWith(isSending: true, error: null);
    try {
      final message = await _chatRepository.sendMessage(sessionId, messageText);
      
      // Remove any pending messages with the same text and add the real message
      final updatedMessages = state.messages
          .where((m) => !(m.metadata?['isPending'] == true && m.messageText == messageText))
          .toList();
      
      state = state.copyWith(
        messages: [message, ...updatedMessages],
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> refreshMessages() async {
    await loadMessages();
  }

  void addMessage(MessageModel message) {
    final updatedMessages = [message, ...state.messages];
    state = state.copyWith(messages: updatedMessages);
  }
}

// Family provider for different chat sessions
final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, sessionId) {
    final chatRepository = ref.watch(chatRepositoryProvider);
    return ChatNotifier(chatRepository, sessionId);
  },
);
