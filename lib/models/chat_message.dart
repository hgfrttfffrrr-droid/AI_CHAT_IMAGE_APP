enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == MessageRole.user;

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'role': role.name,
        'timestamp': timestamp.toIso8601String(),
        'isError': isError,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        content: json['content'] as String,
        role: MessageRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => MessageRole.assistant,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isError: json['isError'] as bool? ?? false,
      );

  /// Converts to the {role, content} map shape expected by the OpenAI API.
  Map<String, String> toApiMessage() => {
        'role': role == MessageRole.user ? 'user' : 'assistant',
        'content': content,
      };
}
