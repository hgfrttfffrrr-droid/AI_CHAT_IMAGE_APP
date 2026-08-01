import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/openrouter_service.dart';

class ChatProvider extends ChangeNotifier {
  static const _storageKey = 'chat_history_v1';
  final OpenRouterService _service;
  final _uuid = const Uuid();

  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  String? _lastError;

  ChatProvider({OpenRouterService? service})
      : _service = service ?? OpenRouterService() {
    _loadHistory();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get lastError => _lastError;

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _messages.addAll(
          list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)),
        );
        notifyListeners();
      }
    } catch (_) {
      // Corrupted local history should never crash the app.
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_messages.map((m) => m.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (_) {
      // Persisting is best-effort; ignore storage failures.
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _lastError = null;
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: trimmed,
      role: MessageRole.user,
    );
    _messages.add(userMessage);
    _isSending = true;
    notifyListeners();
    unawaited(_saveHistory());

    try {
      final reply = await _service.sendChatMessage(history: _messages);
      _messages.add(
        ChatMessage(
          id: _uuid.v4(),
          content: reply,
          role: MessageRole.assistant,
        ),
      );
    } on OpenRouterException catch (e) {
      _lastError = e.message;
      _messages.add(
        ChatMessage(
          id: _uuid.v4(),
          content: e.message,
          role: MessageRole.assistant,
          isError: true,
        ),
      );
    } finally {
      _isSending = false;
      notifyListeners();
      unawaited(_saveHistory());
    }
  }

  Future<void> clearHistory() async {
    _messages.clear();
    _lastError = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

// Small helper so we don't need to import dart:async just for this.
void unawaited(Future<void> future) {}
