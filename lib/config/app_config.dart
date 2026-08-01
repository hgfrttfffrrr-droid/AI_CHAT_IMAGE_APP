import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized app configuration: API keys, model names, and theme.
class AppConfig {
  AppConfig._();

  static String get openRouterApiKey =>
      dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get chatModel =>
      dotenv.env['CHAT_MODEL'] ?? 'google/gemini-flash-latest';
  static String get imageModel =>
      dotenv.env['IMAGE_MODEL'] ?? 'google/gemini-2.5-flash-image';

  /// Optional but recommended by OpenRouter for attributing/ranking apps.
  static String get siteUrl =>
      dotenv.env['SITE_URL'] ?? 'https://example.com';
  static String get appTitle =>
      dotenv.env['APP_TITLE'] ?? 'AI Chat & Image Generator';

  static bool get isApiKeyConfigured =>
      openRouterApiKey.isNotEmpty &&
      !openRouterApiKey.contains('your-openrouter-api-key-here');

  static const String baseUrl = 'https://openrouter.ai/api/v1';

  // Brand palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF00C2A8);
  static const Color background = Color(0xFFF5F6FA);
  static const Color darkBackground = Color(0xFF13131A);
  static const Color userBubble = Color(0xFF6C63FF);
  static const Color aiBubble = Color(0xFFFFFFFF);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E28),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
