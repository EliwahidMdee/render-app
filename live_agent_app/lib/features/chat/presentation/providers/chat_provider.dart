import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  static const String _boxName = 'temp_messages';

  ChatNotifier(this._chatRepository, this.sessionId) : super(ChatState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await Hive.initFlutter();
      // store lists of message maps keyed by sessionId
      await Hive.openBox<List>(_boxName);
    } catch (_) {}

    final cached = _readMessagesFromBox();
    if (cached.isNotEmpty) {
      state = state.copyWith(messages: cached);
    }

    // Load fresh in background
    refreshMessages();
  }

  List<MessageModel> _readMessagesFromBox() {
    try {
      final box = Hive.box<List>(_boxName);
      final raw = box.get(sessionId);
      if (raw == null) return [];
      return (raw as List).map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeMessagesToBox(List<MessageModel> messages) async {
    try {
      final box = Hive.box<List>(_boxName);
      final raw = messages.map((m) => m.toJson()).toList();
      await box.put(sessionId, raw);
    } catch (_) {}
  }

  Future<void> loadMessages() async {
    // Read from cache first
    final cached = _readMessagesFromBox();
    if (cached.isNotEmpty) {
      state = state.copyWith(messages: cached, isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _chatRepository.getMessages(sessionId);
      final reversed = messages.reversed.toList();
      await _writeMessagesToBox(reversed);
      state = state.copyWith(messages: reversed, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    state = state.copyWith(isSending: true, error: null);
    try {
      final message = await _chatRepository.sendMessage(sessionId, messageText);

      // Remove pending duplicates and add real message at top
      final updatedMessages = state.messages.where((m) => !(m.metadata?['isPending'] == true && m.messageText == messageText)).toList();
      final newList = [message, ...updatedMessages];

      await _writeMessagesToBox(newList);

      state = state.copyWith(messages: newList, isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> refreshMessages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _chatRepository.getMessages(sessionId);
      final reversed = messages.reversed.toList();
      await _writeMessagesToBox(reversed);
      final fromBox = _readMessagesFromBox();
      state = state.copyWith(messages: fromBox, isLoading: false);
    } catch (e) {
      final fromBox = _readMessagesFromBox();
      state = state.copyWith(messages: fromBox, isLoading: false, error: e.toString());
    }
  }

  void addMessage(MessageModel message) {
    final updatedMessages = [message, ...state.messages];
    state = state.copyWith(messages: updatedMessages);
    // Update cache so UI persists pending message
    _writeMessagesToBox(updatedMessages);
  }
}

// Family provider for different chat sessions
final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, sessionId) {
    final chatRepository = ref.watch(chatRepositoryProvider);
    return ChatNotifier(chatRepository, sessionId);
  },
);
