class MessageModel {
  final int messageId;
  final String sessionId;
  final String senderType;
  final String? senderId;
  final String senderName;
  final String messageText;
  final DateTime createdAt;
  final bool readByUser;
  final bool readByAgent;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.messageId,
    required this.sessionId,
    required this.senderType,
    this.senderId,
    required this.senderName,
    required this.messageText,
    required this.createdAt,
    this.readByUser = false,
    this.readByAgent = false,
    this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'] ?? json['id'] ?? 0,
      sessionId: json['session_id'] ?? '',
      senderType: json['sender_type'] ?? 'user',
      senderId: json['sender_id'],
      senderName: json['sender_name'] ?? 'Unknown',
      messageText: json['message_text'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      readByUser: json['read_by_user'] ?? false,
      readByAgent: json['read_by_agent'] ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'session_id': sessionId,
      'sender_type': senderType,
      'sender_id': senderId,
      'sender_name': senderName,
      'message_text': messageText,
      'created_at': createdAt.toIso8601String(),
      'read_by_user': readByUser,
      'read_by_agent': readByAgent,
      'metadata': metadata,
    };
  }

  MessageModel copyWith({
    int? messageId,
    String? sessionId,
    String? senderType,
    String? senderId,
    String? senderName,
    String? messageText,
    DateTime? createdAt,
    bool? readByUser,
    bool? readByAgent,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      sessionId: sessionId ?? this.sessionId,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      messageText: messageText ?? this.messageText,
      createdAt: createdAt ?? this.createdAt,
      readByUser: readByUser ?? this.readByUser,
      readByAgent: readByAgent ?? this.readByAgent,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isFromAgent => senderType == 'agent';
  bool get isFromUser => senderType == 'user';
}
