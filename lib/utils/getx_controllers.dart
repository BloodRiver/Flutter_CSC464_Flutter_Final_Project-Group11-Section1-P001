import 'package:ai_language_tutor/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final Rxn<Conversation> _currentConversation = Rxn<Conversation>();

  Conversation? get conversation => _currentConversation.value;

  ChatController({required Conversation conversation}) {
    _currentConversation.value = conversation;
  }

  void setConversation(Conversation newConv) {
    _currentConversation.value = newConv;
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

    print("ChatHistoryController onInit: $currentUserid");

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
