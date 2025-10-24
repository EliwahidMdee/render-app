import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/session_repository.dart';

// Session Repository Provider
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SessionRepository(dioClient);
});

// Sessions State Provider
class SessionsState {
  final List<SessionModel> sessions;
  final bool isLoading;
  final String? error;
  final String? selectedStatus;

  SessionsState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
    this.selectedStatus,
  });

  SessionsState copyWith({
    List<SessionModel>? sessions,
    bool? isLoading,
    String? error,
    String? selectedStatus,
  }) {
    return SessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

class SessionsNotifier extends StateNotifier<SessionsState> {
  final SessionRepository _sessionRepository;

  SessionsNotifier(this._sessionRepository) : super(SessionsState()) {
    loadSessions();
  }

  Future<void> loadSessions({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _sessionRepository.getSessions(
        status: status ?? state.selectedStatus,
      );
      state = state.copyWith(
        sessions: sessions,
        isLoading: false,
        selectedStatus: status ?? state.selectedStatus,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshSessions() async {
    await loadSessions(status: state.selectedStatus);
  }

  Future<void> assignSession(String sessionId, String agentId, String agentName) async {
    try {
      await _sessionRepository.assignSession(sessionId, agentId, agentName);
      await refreshSessions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> closeSession(String sessionId) async {
    try {
      await _sessionRepository.closeSession(sessionId);
      await refreshSessions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void filterByStatus(String? status) {
    loadSessions(status: status);
  }
}

final sessionsProvider = StateNotifierProvider<SessionsNotifier, SessionsState>((ref) {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return SessionsNotifier(sessionRepository);
});
