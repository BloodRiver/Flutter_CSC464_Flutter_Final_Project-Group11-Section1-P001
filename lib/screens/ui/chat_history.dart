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
      appBar: AppBar(
        actions: [
          FilledButton(
            onPressed: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                spacing: 5,
                children: [Icon(Icons.delete), Text("Delete Selected")],
              ),
            ),
          ),
        ],
      ),
      body: Expanded(
        child: ListView(
          children: [
            ListTile(
              title: Text("Conversation 1"),
              trailing: Icon(Icons.more_horiz),
            ),
            ListTile(
              title: Text("Conversation 1"),
              trailing: Icon(Icons.more_horiz),
            ),
            ListTile(
              title: Text("Conversation 1"),
              trailing: Icon(Icons.more_horiz),
            ),
          ],
        ),
      ),
    );
  }
}
