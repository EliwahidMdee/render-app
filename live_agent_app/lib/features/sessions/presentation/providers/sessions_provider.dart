import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  static const String _boxName = 'temp_sessions';

  SessionsNotifier(this._sessionRepository) : super(SessionsState()) {
    _init();
  }

  // Initialize Hive box and load cached sessions into state
  Future<void> _init() async {
    try {
      if (!Hive.isAdapterRegistered(0)) {
        // We are not registering adapters; store as Map<String, dynamic> via toJson
      }
      await Hive.initFlutter();
      await Hive.openBox<List>(_boxName);
    } catch (_) {
      // ignore init errors -- box may already be open or Hive was inited elsewhere
    }

    // Load cached sessions (if any)
    final cached = _readSessionsFromBox();
    if (cached.isNotEmpty) {
      state = state.copyWith(sessions: cached);
    }

    // Then attempt to fetch fresh in background without blocking UI
    refreshSessions();
  }

  List<SessionModel> _readSessionsFromBox() {
    try {
      final box = Hive.box<List>(_boxName);
      final raw = box.get('sessions');
      if (raw == null || raw is! List) return [];
      return raw.map((m) => SessionModel.fromJson(Map<String, dynamic>.from(m as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeSessionsToBox(List<SessionModel> sessions) async {
    try {
      final box = Hive.box<List>(_boxName);
      final raw = sessions.map((s) => s.toJson()).toList();
      await box.put('sessions', raw);
    } catch (e) {
      // ignore box write errors for now but keep logging if logger available
    }
  }

  // Load sessions from cache (state) or API if needed
  Future<void> loadSessions({String? status}) async {
    // Keep UI responsive: read from cache first
    final cached = _readSessionsFromBox();
    if (cached.isNotEmpty) {
      state = state.copyWith(
        sessions: _applyStatusFilter(cached, status),
        isLoading: false,
        selectedStatus: status ?? state.selectedStatus,
      );
      return;
    }

    // If no cache, fetch from API
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _sessionRepository.getSessions(status: status ?? state.selectedStatus);
      await _writeSessionsToBox(sessions);
      state = state.copyWith(
        sessions: _applyStatusFilter(sessions, status),
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Fetch latest data from API
      final sessions = await _sessionRepository.getSessions(status: state.selectedStatus);
      // Write latest to temp box first (so UI reads from cache)
      await _writeSessionsToBox(sessions);
      final fromBox = _readSessionsFromBox();
      state = state.copyWith(
        sessions: _applyStatusFilter(fromBox, state.selectedStatus),
        isLoading: false,
      );
    } catch (e) {
      // If refresh fails, keep existing cached data
      final fromBox = _readSessionsFromBox();
      state = state.copyWith(
        sessions: _applyStatusFilter(fromBox, state.selectedStatus),
        isLoading: false,
        error: e.toString(),
      );
    }
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
    // Apply filter to the currently cached list
    final cached = _readSessionsFromBox();
    state = state.copyWith(
      sessions: _applyStatusFilter(cached, status),
      selectedStatus: status,
    );
    // Also fetch fresh data for that status in background
    refreshSessions();
  }

  List<SessionModel> _applyStatusFilter(List<SessionModel> sessions, String? status) {
    if (status == null) return sessions;
    return sessions.where((s) => s.status == status).toList();
  }
}

final sessionsProvider = StateNotifierProvider<SessionsNotifier, SessionsState>((ref) {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return SessionsNotifier(sessionRepository);
});
