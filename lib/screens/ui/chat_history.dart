import 'package:ai_language_tutor/utils/getx_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  late ChatHistoryController historyController;

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        title: const Text(
          "Delete Conversations",
          style: TextStyle(color: Colors.white),
        ),
        content: Obx(
          () => Text(
            "Delete ${historyController.selectedIds.length} items permanently?",
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              historyController.deleteSelected();
              Navigator.pop(context);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    historyController = Get.put(ChatHistoryController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Obx(
          () => Text(
            historyController.isSelectionMode.value
                ? "${historyController.selectedIds.length} Selected"
                : "Chat History",
          ),
        ),
        actions: [
          // DELETE BUTTON (Only shows if something is selected)
          Obx(
            () => historyController.selectedIds.isNotEmpty
                ? FilledButton(
                    onPressed: _confirmDelete,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.fromMap({
                        WidgetState.any: Colors.red.shade700,
                      }),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 12,
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          const Icon(Icons.delete_outline, color: Colors.white),
                          Text(
                            "Delete Selected",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
          ),

          // SELECT ALL / DESELECT TOGGLE
          Obx(
            () => IconButton(
              icon: Icon(
                historyController.isSelectionMode.value
                    ? Icons.close
                    : Icons.edit_note,
                color: Colors.white,
              ),
              onPressed: () {
                historyController.isSelectionMode.toggle();
                historyController.selectedIds.clear();
              },
            ),
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
                onChanged: (val) => historyController.searchQuery.value = val,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search conversations...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.search, color: accentBlue),
                  suffixIcon: Obx(
                    () => historyController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white38,
                              size: 18,
                            ),
                            onPressed: () {
                              historyController.searchQuery.value = "";
                            },
                          )
                        : const SizedBox(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          Obx(
            () => historyController.isSelectionMode.value
                ? Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Row(
                      spacing: 5,
                      children: [
                        Obx(() {
                          final bool isAllSelected =
                              historyController.selectedIds.length ==
                                  historyController.conversations.length &&
                              historyController.conversations.isNotEmpty;
                          return Checkbox(
                            semanticLabel: "Select All",
                            value: isAllSelected,
                            onChanged: (bool? newValue) {
                              historyController.selectAll(newValue ?? false);
                            },
                          );
                        }),
                        Text(
                          "Select All",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Obx(
                          () => Text(
                            "${historyController.conversations.length} total",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),

          // LIST
          Expanded(
            child: Obx(() {
              final items = historyController.filteredItems;

              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    "No chats found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final item = items[index];

                  final isSelected = historyController.selectedIds.contains(
                    item.id,
                  );

                  return GestureDetector(
                    onLongPress: () {
                      historyController.isSelectionMode.value = true;
                      historyController.toggleSelection(item.id!);
                    },
                    onTap: () {
                      if (historyController.isSelectionMode.value) {
                        historyController.toggleSelection(item.id!);
                      } else {
                        // TODO: Load and open Conversation
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentBlue.withAlpha(15)
                            : cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? accentBlue : borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Dynamic Leading: Show Checkbox if in Selection Mode
                          if (historyController.isSelectionMode.value)
                            Checkbox(
                              value: isSelected,
                              activeColor: accentBlue,
                              onChanged: (val) {
                                historyController.toggleSelection(item.id!);
                              },
                            )
                          else
                            CircleAvatar(
                              backgroundColor: borderColor.withAlpha(50),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item.dateCreated.toIso8601String(),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!historyController.isSelectionMode.value)
                            PopupMenuButton(
                              onSelected: (String result) {
                                // TODO Perform delete
                              },
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white24,
                              ),
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: "Edit",
                                      child: Text("Edit Name"),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: "Delete",
                                      child: Text("Delete Chat"),
                                    ),
                                  ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
