import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/chat_message.dart';

/// Thrown when the OpenRouter API returns a non-success response.
class OpenRouterException implements Exception {
  final String message;
  final int? statusCode;
  OpenRouterException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Result of an image generation call: raw decoded image bytes + mime type.
class GeneratedImageBytes {
  final Uint8List bytes;
  final String mediaType;
  GeneratedImageBytes({required this.bytes, required this.mediaType});
}

/// A thin wrapper around the OpenRouter REST API (openrouter.ai).
///
/// OpenRouter is OpenAI-compatible for chat:
///  - POST /chat/completions  -> text responses (LLM chat), e.g. model
///    "google/gemini-flash-latest"
///
/// but uses its OWN dedicated endpoint for images (NOT OpenAI's
/// /images/generations shape):
///  - POST /images -> returns base64-encoded image bytes (b64_json),
///    e.g. model "google/gemini-2.5-flash-image"
class OpenRouterService {
  final http.Client _client;

  OpenRouterService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConfig.openRouterApiKey}',
        // Optional but recommended by OpenRouter: attributes your app on
        // https://openrouter.ai rankings/dashboard. Safe to leave as-is.
        'HTTP-Referer': AppConfig.siteUrl,
        'X-Title': AppConfig.appTitle,
      };

  /// Sends the full conversation history and returns the assistant's reply.
  Future<String> sendChatMessage({
    required List<ChatMessage> history,
    String systemPrompt =
        'You are a helpful, friendly, and concise AI assistant.',
  }) async {
    _assertApiKey();

    final uri = Uri.parse('${AppConfig.baseUrl}/chat/completions');

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => m.toApiMessage()),
    ];

    try {
      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'model': AppConfig.chatModel,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw OpenRouterException(
          _extractErrorMessage(data),
          statusCode: response.statusCode,
        );
      }

      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw OpenRouterException('No response returned from the model.');
      }

      final content = choices.first['message']?['content'] as String? ?? '';
      return content.trim();
    } on OpenRouterException {
      rethrow;
    } catch (e) {
      throw OpenRouterException('Network error: ${e.toString()}');
    }
  }

  /// Generates an image from a text prompt using OpenRouter's dedicated
  /// Image API (POST /images), and returns the decoded bytes.
  ///
  /// [size] accepts either a resolution tier ("1K", "2K", "4K") or explicit
  /// pixel dimensions ("1024x1024"), per OpenRouter's `size` shorthand.
  Future<GeneratedImageBytes> generateImage({
    required String prompt,
    String size = '1024x1024',
  }) async {
    _assertApiKey();

    final uri = Uri.parse('${AppConfig.baseUrl}/images');

    try {
      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'model': AppConfig.imageModel,
          'prompt': prompt,
          'size': size,
          'n': 1,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw OpenRouterException(
          _extractErrorMessage(data),
          statusCode: response.statusCode,
        );
      }

      final list = data['data'] as List<dynamic>?;
      if (list == null || list.isEmpty) {
        throw OpenRouterException('No image returned from the model.');
      }

      final first = list.first as Map<String, dynamic>;
      final b64 = first['b64_json'] as String?;
      if (b64 == null) {
        throw OpenRouterException('Image data missing in API response.');
      }
      final mediaType = first['media_type'] as String? ?? 'image/png';

      return GeneratedImageBytes(
        bytes: base64Decode(b64),
        mediaType: mediaType,
      );
    } on OpenRouterException {
      rethrow;
    } catch (e) {
      throw OpenRouterException('Network error: ${e.toString()}');
    }
  }

  String _extractErrorMessage(Map<String, dynamic> data) {
    final error = data['error'];
    if (error is Map && error['message'] != null) {
      return error['message'].toString();
    }
    return 'Something went wrong while contacting OpenRouter.';
  }

  void _assertApiKey() {
    if (!AppConfig.isApiKeyConfigured) {
      throw OpenRouterException(
        'Missing OpenRouter API key. Add it to the .env file '
        '(OPENROUTER_API_KEY=sk-or-v1-...) and restart the app.',
      );
    }
  }

  void dispose() => _client.close();
}
