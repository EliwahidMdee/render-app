class SessionModel {
  final String sessionId;
  final String tenantDomain;
  final String userAccount;
  final String userName;
  final String? assignedAgentId;
  final String? assignedAgentName;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final int unreadCountUser;
  final int unreadCountAgent;
  final String? messagePreview;
  final Map<String, dynamic>? metadata;

  SessionModel({
    required this.sessionId,
    required this.tenantDomain,
    required this.userAccount,
    required this.userName,
    this.assignedAgentId,
    this.assignedAgentName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.unreadCountUser = 0,
    this.unreadCountAgent = 0,
    this.messagePreview,
    this.metadata,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['session_id'] ?? json['id'] ?? '',
      tenantDomain: json['tenant_domain'] ?? '',
      userAccount: json['user_account'] ?? '',
      userName: json['user_name'] ?? '',
      assignedAgentId: json['assigned_agent_id']?.toString(),
      assignedAgentName: json['assigned_agent_name'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      lastMessageAt: json['last_message_at'] != null 
          ? DateTime.parse(json['last_message_at'])
          : null,
      unreadCountUser: json['unread_count_user'] ?? 0,
      unreadCountAgent: json['unread_count_agent'] ?? 0,
      messagePreview: json['preview'] ?? json['message_preview'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'tenant_domain': tenantDomain,
      'user_account': userAccount,
      'user_name': userName,
      'assigned_agent_id': assignedAgentId,
      'assigned_agent_name': assignedAgentName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count_user': unreadCountUser,
      'unread_count_agent': unreadCountAgent,
      'preview': messagePreview,
      'metadata': metadata,
    };
  }

  SessionModel copyWith({
    String? sessionId,
    String? tenantDomain,
    String? userAccount,
    String? userName,
    String? assignedAgentId,
    String? assignedAgentName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
    int? unreadCountUser,
    int? unreadCountAgent,
    String? messagePreview,
    Map<String, dynamic>? metadata,
  }) {
    return SessionModel(
      sessionId: sessionId ?? this.sessionId,
      tenantDomain: tenantDomain ?? this.tenantDomain,
      userAccount: userAccount ?? this.userAccount,
      userName: userName ?? this.userName,
      assignedAgentId: assignedAgentId ?? this.assignedAgentId,
      assignedAgentName: assignedAgentName ?? this.assignedAgentName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCountUser: unreadCountUser ?? this.unreadCountUser,
      unreadCountAgent: unreadCountAgent ?? this.unreadCountAgent,
      messagePreview: messagePreview ?? this.messagePreview,
      metadata: metadata ?? this.metadata,
    );
  }
}
