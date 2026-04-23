import 'package:ai_language_tutor/screens/ui/chat.dart';
import 'package:ai_language_tutor/screens/ui/chat_history.dart';
import 'package:ai_language_tutor/screens/ui/home.dart';
import 'package:ai_language_tutor/utils/getx_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.put(
      NavigationController(),
    );
    return Scaffold(
      body: PageView(
        controller: navigationController.pageController,
        onPageChanged: (index) =>
            navigationController.currentPageIndex.value = index,
        children: [HomePage(), ChatScreen(), ChatHistoryScreen()],
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: navigationController.currentPageIndex.value,
          onDestinationSelected: (index) =>
              navigationController.changePage(index),
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.chat), label: "Chat"),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: "Chat History",
            ),
          ],
        ),
      ),
    );
  }
}
