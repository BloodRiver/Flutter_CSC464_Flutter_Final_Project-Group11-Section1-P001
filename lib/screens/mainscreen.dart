import 'package:ai_language_tutor/screens/ui/chat.dart';
import 'package:ai_language_tutor/screens/ui/home.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          HomePage(),
          ChatScreen(selectedLanguage: "English"),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          _pageController.animateToPage(
            i,
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.chat), label: "Chat"),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: "Chat History",
          ),
        ],
      ),
    );
  }
}
