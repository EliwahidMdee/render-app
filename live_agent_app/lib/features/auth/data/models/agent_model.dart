class AgentModel {
  final String id;
  final String email;
  final String name;
  final bool isOnline;
  final String? fcmToken;

  AgentModel({
    required this.id,
    required this.email,
    required this.name,
    this.isOnline = false,
    this.fcmToken,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? json['agent_email'] ?? '',
      name: (json['name'] ?? json['full_name'] ?? json['agent_name'] ?? '').toString().trim(),
      isOnline: json['is_online'] ?? false,
      fcmToken: json['fcm_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'is_online': isOnline,
      'fcm_token': fcmToken,
    };
  }

  AgentModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? isOnline,
    String? fcmToken,
  }) {
    return AgentModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isOnline: isOnline ?? this.isOnline,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
