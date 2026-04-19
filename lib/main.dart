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
    return MaterialApp(
      title: 'AI Language Learning App (Gemini API Chat)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006D77)),
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
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Bangla',
    'Arabic',
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
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Project: AI Language Learning App (Gemini API Chat)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _navigateToChatScreen,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Navigate to chat screen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
                      child: Text('Start chatting with your AI tutor.'),
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
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(message.text),
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
