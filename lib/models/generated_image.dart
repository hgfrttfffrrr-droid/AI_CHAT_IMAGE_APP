import 'dart:typed_data';

class GeneratedImage {
  final String id;
  final String prompt;
  final Uint8List bytes;
  final String mediaType;
  final DateTime createdAt;

  GeneratedImage({
    required this.id,
    required this.prompt,
    required this.bytes,
    this.mediaType = 'image/png',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
