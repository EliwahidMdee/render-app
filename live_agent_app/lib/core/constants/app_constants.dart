import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'SmartBiashara- Customer Support';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String agentIdKey = 'agent_id';
  static const String agentEmailKey = 'agent_email';
  static const String agentNameKey = 'agent_name';
  static const String darkModeKey = 'dark_mode';
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
  // Primary Colors - Modern vibrant blue gradient
  static const Color primary = Color(0xFF0D47A1); // Deep Blue
  static const Color primaryDark = Color(0xFF002171); // Darker Blue
  static const Color primaryLight = Color(0xFF5472D3); // Lighter Blue
  
  // Accent Colors - Complementary Cyan
  static const Color accent = Color(0xFF00BCD4); // Cyan
  static const Color accentDark = Color(0xFF008BA3); // Dark Cyan
  
  // Status Colors
  static const Color success = Color(0xFF2E7D32); // Deep Green
  static const Color warning = Color(0xFFF57C00); // Deep Orange
  static const Color error = Color(0xFFC62828); // Deep Red
  static const Color info = Color(0xFF1976D2); // Blue
  
  // Session Status Colors
  static const Color statusPending = Color(0xFFF57C00); // Orange
  static const Color statusActive = Color(0xFF2E7D32); // Green
  static const Color statusResolved = Color(0xFF757575); // Grey
  static const Color statusClosed = Color(0xFF616161); // Dark Grey
  
  // Background Colors
  static const Color background = Color(0xFFF5F7FA); // Light Grey Blue
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceDark = Color(0xFF121212); // Dark
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost Black
  static const Color textSecondary = Color(0xFF666666); // Medium Grey
  static const Color textHint = Color(0xFF999999); // Light Grey
  
  // Message Bubble Colors - WhatsApp inspired
  static const Color userMessageBubble = Color(0xFFDCF8C6); // Light Green (user)
  static const Color agentMessageBubble = Color(0xFFFFFFFF); // White (agent)
  
  // Online/Offline Status
  static const Color online = Color(0xFF4CAF50); // Green
  static const Color offline = Color(0xFF9E9E9E); // Grey
  static const Color busy = Color(0xFFF57C00); // Orange
}
