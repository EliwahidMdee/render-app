class ApiConstants {
  // Base URL - Change this to your backend URL
  static const String baseUrl = 'https://api.example.com';
  
  // Endpoints
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String sessionsEndpoint = '/api/v1/live-agent/sessions';
  static const String messagesEndpoint = '/api/v1/live-agent/messages';
  static const String agentStatusEndpoint = '/api/v1/live-agent/agent/status';
  
  // Timeouts (60 seconds as per requirements)
  static const int connectTimeout = 60000;
  static const int receiveTimeout = 60000;
}
