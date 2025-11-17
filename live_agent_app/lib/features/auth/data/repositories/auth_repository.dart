import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/agent_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorage _storage;

  AuthRepository(this._dioClient, this._storage);

  Future<AgentModel> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.loginEndpoint,
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
    final token = await _storage.read(AppConstants.jwtTokenKey);
    final id = await _storage.read(AppConstants.agentIdKey);
    final email = await _storage.read(AppConstants.agentEmailKey);
    final name = await _storage.read(AppConstants.agentNameKey);

    // If we already have the basics in storage, return them immediately
    if (id != null && email != null) {
      return AgentModel(
        id: id,
        email: email,
        name: name ?? email,
      );
    }

    // If storage is missing info but we have a token, try fetching from the API
    if (token != null && token.isNotEmpty) {
      try {
        final response = await _dioClient.dio.get(ApiConstants.profileEndpoint);
        final userJson = response.data['user'] ?? response.data['agent'] ?? response.data;
        final fetched = AgentModel.fromJson(userJson);

        if (fetched.id.isNotEmpty) {
          await _storage.write(AppConstants.agentIdKey, fetched.id);
        }
        if (fetched.email.isNotEmpty) {
          await _storage.write(AppConstants.agentEmailKey, fetched.email);
        }
        if (fetched.name.isNotEmpty) {
          await _storage.write(AppConstants.agentNameKey, fetched.name);
        }

        return fetched;
      } on DioException catch (e) {
        AppLogger.error('Fetch current agent failed', e);
        return null;
      } catch (e) {
        AppLogger.error('Fetch current agent error', e);
        return null;
      }
    }

    // No token or data available
    return null;
  }

  /// Update authenticated user's profile. Expects a map with optional keys: full_name, email, password
  Future<AgentModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.profileEndpoint,
        data: data,
      );

      final userJson = response.data['user'] ?? response.data['agent'] ?? response.data;
      final updatedAgent = AgentModel.fromJson(userJson);

      // Persist updated values if present
      if (updatedAgent.id.isNotEmpty) {
        await _storage.write(AppConstants.agentIdKey, updatedAgent.id);
      }
      if (updatedAgent.email.isNotEmpty) {
        await _storage.write(AppConstants.agentEmailKey, updatedAgent.email);
      }
      if (updatedAgent.name.isNotEmpty) {
        await _storage.write(AppConstants.agentNameKey, updatedAgent.name);
      }

      AppLogger.info('Profile updated for agent: ${updatedAgent.email}');
      return updatedAgent;
    } on DioException catch (e) {
      AppLogger.error('Profile update failed', e);
      throw Exception('Profile update failed: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      AppLogger.error('Profile update error', e);
      throw Exception('Profile update failed: $e');
    }
  }
}
