import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    final bubbleColor = message.isError
        ? theme.colorScheme.errorContainer
        : isUser
            ? AppConfig.primary
            : theme.brightness == Brightness.dark
                ? const Color(0xFF23232E)
                : Colors.white;
    final textColor = message.isError
        ? theme.colorScheme.onErrorContainer
        : isUser
            ? Colors.white
            : theme.textTheme.bodyLarge?.color;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.isError)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 16, color: textColor),
                  const SizedBox(width: 6),
                  Text('Error',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold)),
                ],
              ),
            if (message.isError) const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.35),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('h:mm a').format(message.timestamp),
              style: TextStyle(
                color: textColor?.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
