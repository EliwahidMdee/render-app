import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/agent_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorage _storage;

  AuthRepository(this._dioClient, this._storage);

  Future<AgentModel> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
          'role': 'agent',
        },
      );

      final token = response.data['access_token'] ?? response.data['token'];
      final agent = AgentModel.fromJson(
        response.data['agent'] ?? response.data['user'] ?? response.data,
      );

      // Store JWT token and agent details securely
      await _storage.write(AppConstants.jwtTokenKey, token);
      await _storage.write(AppConstants.agentIdKey, agent.id);
      await _storage.write(AppConstants.agentEmailKey, agent.email);
      await _storage.write(AppConstants.agentNameKey, agent.name);

      AppLogger.info('Login successful for agent: ${agent.email}');
      return agent;
    } on DioException catch (e) {
      AppLogger.error('Login failed', e);
      throw Exception('Login failed: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      AppLogger.error('Login error', e);
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _storage.deleteAll();
      AppLogger.info('Logout successful');
    } catch (e) {
      AppLogger.error('Logout error', e);
      throw Exception('Logout failed: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(AppConstants.jwtTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<AgentModel?> getCurrentAgent() async {
    final id = await _storage.read(AppConstants.agentIdKey);
    final email = await _storage.read(AppConstants.agentEmailKey);
    final name = await _storage.read(AppConstants.agentNameKey);

    if (id == null || email == null) {
      return null;
    }

    return AgentModel(
      id: id,
      email: email,
      name: name ?? email,
    );
  }
}
