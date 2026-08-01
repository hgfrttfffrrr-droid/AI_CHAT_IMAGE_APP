import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/generated_image.dart';
import '../services/openrouter_service.dart';

class ImageGenProvider extends ChangeNotifier {
  final OpenRouterService _service;
  final _uuid = const Uuid();

  final List<GeneratedImage> _images = [];
  bool _isGenerating = false;
  String? _lastError;

  ImageGenProvider({OpenRouterService? service})
      : _service = service ?? OpenRouterService();

  List<GeneratedImage> get images => List.unmodifiable(_images.reversed);
  bool get isGenerating => _isGenerating;
  String? get lastError => _lastError;

  Future<void> generate(String prompt, {String size = '1024x1024'}) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty || _isGenerating) return;

    _isGenerating = true;
    _lastError = null;
    notifyListeners();

    try {
      final result = await _service.generateImage(prompt: trimmed, size: size);
      _images.add(
        GeneratedImage(
          id: _uuid.v4(),
          prompt: trimmed,
          bytes: result.bytes,
          mediaType: result.mediaType,
        ),
      );
    } on OpenRouterException catch (e) {
      _lastError = e.message;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void clearAll() {
    _images.clear();
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
