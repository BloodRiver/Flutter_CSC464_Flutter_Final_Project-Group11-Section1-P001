import 'package:ai_language_tutor/utils/getx_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_language_tutor/models.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String _geminiModel = 'gemini-2.0-flash'; // Updated model name
  static const String _apiKey =
      'Your-API-KEY'; // Use --dart-define in production

  final TextEditingController _messageController = TextEditingController();
  late ChatController _chatController;

  @override
  void initState() {
    super.initState();
    // Use the tag if you initialized it with one, otherwise remove the tag parameter
    _chatController = Get.find<ChatController>(tag: 'currentConv');
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final String userText = _messageController.text.trim();
    if (userText.isEmpty || _chatController.isSending.value) return;

    _messageController.clear();
    await _chatController.sendMessageToGemini(userText, _apiKey, _geminiModel);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final conv = _chatController.currentConversation.value;

      // 1. Check if a conversation is actually active
      if (conv == null || (_chatController.initialized == false)) {
        return _buildNoConversationState();
      }

      return Scaffold(
        backgroundColor: const Color(0xFF050a14),
        appBar: AppBar(
          backgroundColor: const Color(0xFF050a14),
          title: Text(
            '${conv.language} Tutor - ${_chatController.currentConversation.value!.title}',
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            // 2. Chat Message List
            Expanded(
              child: Obx(() {
                final messages = _chatController.messages;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "Say 'Hello' to start your lesson!",
                      style: TextStyle(color: Colors.white38),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse:
                      false, // Set to true if you want messages to start from bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index]);
                  },
                );
              }),
            ),

            // 3. Input Area
            _buildInputArea(),
          ],
        ),
      );
    });
  }

  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = !message.ai;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2F7BFF) : const Color(0xFF0f1a2e),
          borderRadius: BorderRadius.circular(15),
          border: isUser ? null : Border.all(color: const Color(0xFF1e3a8a)),
        ),
        child: Text(
          message.messageContent,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: const BoxDecoration(color: Color(0xFF0a1220)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type message...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF050a14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF1e3a8a)),
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => CircleAvatar(
              backgroundColor: const Color(0xFF2F7BFF),
              child: IconButton(
                icon: _chatController.isSending.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: _chatController.isSending.value ? null : _handleSend,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoConversationState() {
    return Scaffold(
      backgroundColor: const Color(0xFF050a14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.white10,
            ),
            const SizedBox(height: 20),
            const Text(
              "Please select a language to begin",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.find<NavigationController>().changePage(0),
              child: const Text("Go Back Home"),
            ),
          ],
        ),
      ),
    );
  }
}
