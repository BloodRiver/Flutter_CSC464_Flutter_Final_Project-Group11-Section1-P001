import 'dart:convert';

import 'package:ai_language_tutor/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NavigationController extends GetxController {
  var currentPageIndex = 0.obs;

  final PageController pageController = PageController();

  void changePage(int index) {
    currentPageIndex.value = index;
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class ChatController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool initialized = false;

  // Observables
  final Rxn<Conversation> currentConversation = Rxn<Conversation>();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isSending = false.obs;

  // Set the conversation and bind the stream for real-time messages
  void setConversation(Conversation conversation) {
    currentConversation.value = conversation;
    messages.clear();

    // Bind to the messages sub-collection inside the conversation document
    messages.bindStream(
      _db
          .collection('conversations')
          .doc(conversation.id)
          .collection('messages')
          .orderBy('timeSent', descending: false)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ChatMessage.fromFirestore(doc))
                .toList(),
          ),
    );
  }

  // The central logic for sending messages and getting Gemini's response
  Future<void> sendMessageToGemini(
    String userText,
    String apiKey,
    String model,
  ) async {
    if (currentConversation.value == null) return;

    isSending.value = true;
    final String convId = currentConversation.value!.id!;
    final String language = currentConversation.value!.language;

    try {
      // 1. Add User Message to Firestore
      await _db
          .collection('conversations')
          .doc(convId)
          .collection('messages')
          .add({
            'ai': false,
            'messageContent': userText,
            'timeSent': DateTime.now(),
          });

      // 2. Prepare Gemini Prompt
      final String prompt =
          'You are a friendly $language language tutor. '
          'Answer in concise teaching style and include simple examples. '
          'Student message: $userText';

      // 3. API Call
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode != 200)
        throw Exception('Gemini Error: ${response.body}');

      // 4. Parse Response
      final data = jsonDecode(response.body);
      final String botReply =
          data['candidates'][0]['content']['parts'][0]['text'] ??
          'No response generated.';

      // 5. Add AI Message to Firestore
      await _db
          .collection('conversations')
          .doc(convId)
          .collection('messages')
          .add({
            'ai': true,
            'messageContent': botReply.trim(),
            'timeSent': DateTime.now(),
          });
    } catch (e) {
      print("Error: ${e.toString()}");
    } finally {
      isSending.value = false;
    }
  }
}

class ChatHistoryController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  RxList<Conversation> conversations = <Conversation>[].obs;

  var isSelectionMode = false.obs;
  var allSelected = false.obs;
  var selectedIds = <String>{}.obs;
  var searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    String currentUserid = Get.find<User>(tag: 'currentUser').id!;

    conversations.bindStream(
      _db
          .collection(Conversation.collectionName)
          .where('userId', isEqualTo: currentUserid)
          .orderBy('dateCreated', descending: true)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) return <Conversation>[];

            return snapshot.docs
                .map((doc) => Conversation.fromFirestore(doc))
                .toList();
          }),
    );
  }

  List<Conversation> get filteredItems {
    if (searchQuery.isEmpty) {
      return conversations;
    }

    return conversations
        .where(
          (c) =>
              c.title!.toLowerCase().contains(searchQuery.value.toLowerCase()),
        )
        .toList();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void selectAll(bool select) {
    if (select) {
      selectedIds.assignAll(conversations.map((c) => c.id!).toList());
    } else {
      selectedIds.clear();
    }
  }

  Future<void> deleteSelected() async {
    for (String id in selectedIds) {
      await Conversation.deleteById(id);
    }
    selectedIds.clear();
    isSelectionMode.value = false;
  }
}
