import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/models/agent_model.dart';
import '../../data/repositories/auth_repository.dart';

// Providers
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dioClient, storage);
});

// Auth State Provider
class AuthState {
  final bool isLoggedIn;
  final AgentModel? agent;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isLoggedIn = false,
    this.agent,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    AgentModel? agent,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      agent: agent ?? this.agent,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> updateProfile({String? fullName, String? email, String? password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (email != null) data['email'] = email;
      if (password != null) data['password'] = password;

      final updated = await _authRepository.updateProfile(data);
      state = state.copyWith(agent: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final agent = await _authRepository.getCurrentAgent();
        state = state.copyWith(
          isLoggedIn: true,
          agent: agent,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoggedIn: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoggedIn: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final agent = await _authRepository.login(email, password);
      state = state.copyWith(
        isLoggedIn: true,
        agent: agent,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.logout();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
