import 'package:flutter/material.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreen();
}

class _ChatHistoryScreen extends State<ChatHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    // Start coding here for the Chat History Screen
    return Scaffold(
      body: Expanded(
        child: ListView(
          children: [
            ListTile(title: Text("Conversation 1"), trailing: Icon(Icons.abc)),
            ListTile(
              title: Text("Conversation 1"),
              trailing: Icon(Icons.ac_unit),
            ),
            ListTile(
              title: Text("Conversation 1"),
              trailing: Icon(Icons.access_alarm),
            ),
          ],
        ),
      ),
    );
  }
}
