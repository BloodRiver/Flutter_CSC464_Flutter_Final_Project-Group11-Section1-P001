import 'package:flutter/material.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final Color bgColor = const Color(0xFF050a14);
  final Color cardColor = const Color(0xFF0f1a2e);
  final Color accentBlue = const Color(0xFF3b82f6);
  final Color borderColor = const Color(0xFF1e3a8a);

  List<Map<String, String>> historyItems = [
    {"id": "1", "title": "English Conversation: Travel", "date": "Apr 24, 2026"},
    {"id": "2", "title": "Bangla Basics: Greetings", "date": "Apr 23, 2026"},
    {"id": "3", "title": "English Grammar: Past Tense", "date": "Apr 22, 2026"},
    {"id": "4", "title": "Bangla Food Vocabulary", "date": "Apr 21, 2026"},
    {"id": "5", "title": "Daily Routine Practice", "date": "Apr 20, 2026"},
  ];

  List<String> selectedIds = [];
  String searchQuery = "";
  bool isSelectionMode = false; // New flag to track if we are selecting

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        title: const Text("Delete Conversations", style: TextStyle(color: Colors.white)),
        content: Text("Delete ${selectedIds.length} items permanently?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                historyItems.removeWhere((item) => selectedIds.contains(item['id']));
                selectedIds.clear();
                isSelectionMode = false;
              });
              Navigator.pop(context);
            },
            child: const Text("DELETE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = historyItems
        .where((item) => item['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(isSelectionMode ? "${selectedIds.length} Selected" : "Chat History"),
        actions: [
          // DELETE BUTTON (Only shows if something is selected)
          if (selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _confirmDelete,
            ),
          
          // SELECT ALL / DESELECT TOGGLE
          IconButton(
            icon: Icon(isSelectionMode ? Icons.close : Icons.edit_note, color: Colors.white),
            onPressed: () {
              setState(() {
                isSelectionMode = !isSelectionMode;
                if (!isSelectionMode) selectedIds.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0a1220),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search conversations...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.search, color: accentBlue),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // LIST
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final isSelected = selectedIds.contains(item['id']);

                return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      isSelectionMode = true;
                      selectedIds.add(item['id']!);
                    });
                  },
                  onTap: () {
                    if (isSelectionMode) {
                      setState(() {
                        isSelected ? selectedIds.remove(item['id']) : selectedIds.add(item['id']!);
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? accentBlue.withOpacity(0.15) : cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? accentBlue : borderColor, width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        // Dynamic Leading: Show Checkbox if in Selection Mode
                        if (isSelectionMode)
                          Checkbox(
                            value: isSelected,
                            activeColor: accentBlue,
                            onChanged: (val) {
                              setState(() {
                                val! ? selectedIds.add(item['id']!) : selectedIds.remove(item['id']);
                              });
                            },
                          )
                        else
                          CircleAvatar(
                            backgroundColor: borderColor.withOpacity(0.5),
                            child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(item['date']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (!isSelectionMode) const Icon(Icons.chevron_right, color: Colors.white24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}