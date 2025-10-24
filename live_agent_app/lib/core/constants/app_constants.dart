import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Live Agent';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String agentIdKey = 'agent_id';
  static const String agentEmailKey = 'agent_email';
  static const String agentNameKey = 'agent_name';
  static const String fcmTokenKey = 'fcm_token';
  
  // Session Status
  static const String statusPending = 'pending';
  static const String statusActive = 'active';
  static const String statusResolved = 'resolved';
  static const String statusClosed = 'closed';
  
  // Message Sender Types
  static const String senderTypeUser = 'user';
  static const String senderTypeAgent = 'agent';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultMessagesPageSize = 50;
}

class AppColors {
  // Primary Colors - Modern blue gradient
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  // Accent Colors
  static const Color accent = Color(0xFF00BCD4);
  static const Color accentDark = Color(0xFF0097A7);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Session Status Colors
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusResolved = Color(0xFF9E9E9E);
  static const Color statusClosed = Color(0xFF757575);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Message Bubble Colors
  static const Color userMessageBubble = Color(0xFFE3F2FD);
  static const Color agentMessageBubble = Color(0xFFBBDEFB);
  
  // Online/Offline Status
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color busy = Color(0xFFFFC107);
}
