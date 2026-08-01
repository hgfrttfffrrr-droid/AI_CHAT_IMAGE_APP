import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/chat_provider.dart';
import 'providers/image_gen_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env not found — app still runs, but API calls will show a clear error.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ImageGenProvider()),
      ],
      child: MaterialApp(
        title: 'AI Chat & Image Generator',
        debugShowCheckedModeBanner: false,
        theme: AppConfig.lightTheme(),
        darkTheme: AppConfig.darkTheme(),
        themeMode: ThemeMode.system,
        home: const _RootGate(),
      ),
    );
  }
}

/// Shows a one-time warning if the OpenAI API key hasn't been configured yet.
class _RootGate extends StatefulWidget {
  const _RootGate();

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  @override
  void initState() {
    super.initState();
    if (!AppConfig.isApiKeyConfigured) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showKeyDialog());
    }
  }

  void _showKeyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add your OpenRouter API key'),
        content: const Text(
          'To use the chat and image generator, open the .env file in the '
          'project root and set:\n\n'
          'OPENROUTER_API_KEY=sk-or-v1-your-key-here\n\n'
          'Get a key at openrouter.ai/keys, then restart the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}
