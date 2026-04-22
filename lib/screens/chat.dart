import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({required this.selectedLanguage, super.key});

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
        throw Exception(
          'Gemini API error (${response.statusCode}): ${response.body}',
        );
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> candidates =
          decoded['candidates'] as List<dynamic>? ?? <dynamic>[];
      final Map<String, dynamic> firstCandidate = candidates.isNotEmpty
          ? candidates.first as Map<String, dynamic>
          : <String, dynamic>{};
      final Map<String, dynamic> content =
          firstCandidate['content'] as Map<String, dynamic>? ??
          <String, dynamic>{};
      final List<dynamic> parts =
          content['parts'] as List<dynamic>? ?? <dynamic>[];
      final Map<String, dynamic> firstPart = parts.isNotEmpty
          ? parts.first as Map<String, dynamic>
          : <String, dynamic>{};
      final String botReply =
          (firstPart['text'] as String?)?.trim().isNotEmpty == true
          ? firstPart['text'] as String
          : 'I could not generate a response. Please try again.';

      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', text: botReply));
      });
    } catch (error) {
      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', text: 'Error: $error'));
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
      appBar: AppBar(title: Text('${widget.selectedLanguage} Tutor Chat')),
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
