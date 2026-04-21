import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF05070D);
    const Color panel = Color(0xFF0E1628);
    const Color blue = Color(0xFF2F7BFF);
    const Color text = Color(0xFFE8F0FF);

    return MaterialApp(
      title: 'AI Language Learning App (Gemini API Chat)',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: blue,
          secondary: blue,
          surface: panel,
          onPrimary: Colors.white,
          onSurface: text,
        ),
        cardTheme: const CardThemeData(
          color: panel,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFF1B2A4A), width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: text,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF0C1221),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF213968)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF213968)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: blue, width: 1.2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
  
}

class _HomePageState extends State<HomePage> {
  static const List<String> _languages = <String>[
    'English',
    'Bangla',
  ];

  String _selectedLanguage = _languages.first;

  void _navigateToChatScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<ChatScreen>(
        builder: (_) => ChatScreen(selectedLanguage: _selectedLanguage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Language Learning App'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AppLogo(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1F44),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E63B8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to your AI tutor',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose English or Bangla and start chatting to practice instantly.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFABC3F5),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF102A61),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3A73CC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select language',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLanguage,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: _languages
                            .map(
                              (String language) => DropdownMenuItem<String>(
                                value: language,
                                child: Text(language),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedLanguage = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3E87),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4A89E8)),
                  ),
                  child: FilledButton.icon(
                    onPressed: _navigateToChatScreen,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Navigate to chat screen'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF08152F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2F7BFF)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF1B4EB8), Color(0xFF48A0FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.translate_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Language Learning App',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Gemini API Chat Tutor',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFABC3F5),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.selectedLanguage,
    super.key,
  });

  final String selectedLanguage;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String _geminiModel = 'gemini-2.0-flash';
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];

  bool _isSending = false;

  Future<void> _sendMessage() async {
    final String userText = _messageController.text.trim();
    if (userText.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: userText));
      _isSending = true;
    });
    _messageController.clear();

    try {
      if (_apiKey.isEmpty) {
        throw Exception(
          'Missing GEMINI_API_KEY. Run with --dart-define=GEMINI_API_KEY=your_key',
        );
      }

      final String prompt =
          'You are a friendly ${widget.selectedLanguage} language tutor. '
          'Answer in concise teaching style and include simple examples when useful. '
          'Student message: $userText';

      final Uri uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$_apiKey',
      );

      final http.Response response = await http.post(
        uri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'contents': <Map<String, dynamic>>[
            <String, dynamic>{
              'role': 'user',
              'parts': <Map<String, String>>[
                <String, String>{'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Gemini API error (${response.statusCode}): ${response.body}');
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> candidates = decoded['candidates'] as List<dynamic>? ?? <dynamic>[];
      final Map<String, dynamic> firstCandidate =
          candidates.isNotEmpty ? candidates.first as Map<String, dynamic> : <String, dynamic>{};
      final Map<String, dynamic> content =
          firstCandidate['content'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final List<dynamic> parts = content['parts'] as List<dynamic>? ?? <dynamic>[];
      final Map<String, dynamic> firstPart =
          parts.isNotEmpty ? parts.first as Map<String, dynamic> : <String, dynamic>{};
      final String botReply =
          (firstPart['text'] as String?)?.trim().isNotEmpty == true
              ? firstPart['text'] as String
              : 'I could not generate a response. Please try again.';

      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', text: botReply));
      });
    } catch (error) {
      setState(() {
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            text: 'Error: $error',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedLanguage} Tutor Chat'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Start chatting with your AI tutor.',
                        style: TextStyle(color: Color(0xFFABC3F5)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final _ChatMessage message = _messages[index];
                        final bool isUser = message.role == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 320),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF2F7BFF)
                                  : const Color(0xFF101D34),
                              border: Border.all(
                                color: isUser
                                    ? const Color(0xFF4A90FF)
                                    : const Color(0xFF203A69),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : const Color(0xFFE8F0FF),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSending ? null : _sendMessage,
                    child: _isSending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  _ChatMessage({required this.role, required this.text});

  final String role;
  final String text;
}
