class ChatMessage {
  final String text;
  final String senderId;
  final DateTime createdAt;
  final String type;

  ChatMessage({
    required this.text,
    required this.senderId,
    required this.createdAt,
    this.type = 'user',
  });

  Map<String, dynamic> toMap() => {
    'text': text,
    'senderId': senderId,
    'createdAt': createdAt.toIso8601String(),
    'type': type,
  };
}
