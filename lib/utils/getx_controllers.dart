import 'package:ai_language_tutor/models.dart';
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
