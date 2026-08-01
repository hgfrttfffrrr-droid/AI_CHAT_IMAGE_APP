import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_chat_image_app/providers/chat_provider.dart';
import 'package:ai_chat_image_app/providers/image_gen_provider.dart';
import 'package:ai_chat_image_app/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows Chat and Image Gen tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => ImageGenProvider()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Image Gen'), findsOneWidget);
  });
}
