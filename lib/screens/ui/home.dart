import 'package:ai_language_tutor/models.dart';
import 'package:ai_language_tutor/utils/getx_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> _languages = <String>['English', 'Bangla'];

  String _selectedLanguage = _languages.first;
  late User currentUser;

  void _navigateToChatScreen() {
    Conversation newConversation = Conversation(
      dateCreated: DateTime.now(),
      userId: currentUser.id!,
      language: _selectedLanguage,
    );

    newConversation.saveNew();

    if (!Get.isRegistered<ChatController>()) {
      Get.put<ChatController>(
        ChatController(conversation: newConversation),
        permanent: true,
      );
    } else {
      Get.find<ChatController>().setConversation(newConversation);
    }
    Get.find<NavigationController>().changePage(1);

    // TODO: Delete all GetxControllers upon logout
  }

  @override
  void initState() {
    super.initState();

    currentUser = Get.find<User>(tag: "currentUser");
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
