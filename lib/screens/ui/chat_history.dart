import 'package:ai_language_tutor/models.dart';
import 'package:ai_language_tutor/utils/getx_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatHistoryScreen extends StatefulWidget {
  ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final Color bgColor = const Color(0xFF050a14);
  final Color cardColor = const Color(0xFF0f1a2e);
  final Color accentBlue = const Color(0xFF3b82f6);
  final Color borderColor = const Color(0xFF1e3a8a);

  bool _isSelectionMode = false;
  bool _isAllSelected = false;
  final Set<String> _selectedIds = {};

  late ChatHistoryController _historyController;

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
        content: Text(
          "Delete ${_selectedIds.length} items permanently?",
          style: const TextStyle(color: Colors.white70),
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
              for (String eachId in _selectedIds) {
                Conversation.deleteById(eachId);
              }
              Navigator.pop(context);
              _isSelectionMode = false;
              setState(() {});
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _historyController = Get.put(ChatHistoryController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _appBar(),
      body: Column(
        children: [
          _searchBar(),
          _selectAllRow(),

          Expanded(
            child: Obx(() {
              final items = _historyController.filteredItems;

              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    "No chats found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  bool isSelected = _selectedIds.contains(item.id!);

                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (!_selectedIds.contains(item.id!)) {
                          _selectedIds.add(item.id!);
                        } else {
                          _selectedIds.remove(item.id!);
                        }

                        _isSelectionMode = _selectedIds.isNotEmpty;
                      });
                    },

                    onTap: () {
                      if (_isSelectionMode) {
                        setState(() {
                          if (_selectedIds.contains(item.id!)) {
                            _selectedIds.remove(item.id!);
                          } else {
                            _selectedIds.add(item.id!);
                          }
                          _isSelectionMode = _selectedIds.isNotEmpty;
                          _isAllSelected = _selectedIds.length == items.length;
                        });
                      } else {
                        ChatController chatController =
                            Get.find<ChatController>(tag: "currentConv");
                        chatController.setConversation(item);
                        chatController.initialized = true;
                        Get.find<NavigationController>().changePage(1);
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
                          _isSelectionMode
                              ? Checkbox(
                                  value: isSelected,
                                  activeColor: accentBlue,
                                  onChanged: (val) {
                                    setState(() {
                                      isSelected = !isSelected;

                                      if (!isSelected) {
                                        if (_selectedIds.contains(item.id!)) {
                                          _selectedIds.remove(item.id!);
                                        }
                                      } else {
                                        _selectedIds.add(item.id!);
                                      }

                                      _isSelectionMode =
                                          _selectedIds.isNotEmpty;
                                    });
                                  },
                                )
                              : CircleAvatar(
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
                          _isSelectionMode
                              ? const SizedBox()
                              : PopupMenuButton(
                                  onSelected: (String result) {
                                    if (result == "Edit") {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          TextEditingController
                                          newTitleController =
                                              TextEditingController();
                                          return AlertDialog(
                                            backgroundColor: cardColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              side: BorderSide(
                                                color: borderColor,
                                              ),
                                            ),
                                            title: const Text(
                                              "Edit Conversation Title",
                                            ),
                                            content: TextField(
                                              controller: newTitleController,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text(
                                                  "CANCEL",
                                                  style: TextStyle(
                                                    color: Colors.white54,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: accentBlue,
                                                ),
                                                onPressed: () {
                                                  item.updateTitle(
                                                    newTitleController.text
                                                        .trim(),
                                                  );

                                                  newTitleController.dispose();
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "Update",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: cardColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            side: BorderSide(
                                              color: borderColor,
                                            ),
                                          ),
                                          title: const Text(
                                            "Delete Conversation",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          content: Text(
                                            "Delete \"${item.title}\" permanently?",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text(
                                                "CANCEL",
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                              onPressed: () {
                                                Conversation.deleteById(
                                                  item.id!,
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "DELETE",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
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

  Widget _selectAllRow() {
    return _isSelectionMode
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              spacing: 5,
              children: [
                Checkbox(
                  activeColor: accentBlue,
                  semanticLabel: "Select All",
                  value: _isAllSelected,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isAllSelected = newValue ?? false;
                    });
                  },
                ),
                Text(
                  "Select All",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  "${_historyController.conversations.length} total",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Padding _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0a1220),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: TextField(
          onChanged: (val) {
            _historyController.searchQuery.value = val;
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search Conversations...",
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: Icon(Icons.search, color: accentBlue),
            suffixIcon: _historyController.searchQuery.value.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _historyController.searchQuery.value = "";
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white38,
                      size: 18,
                    ),
                  )
                : const SizedBox(),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      title: Text(
        _isSelectionMode ? "${_selectedIds.length} Selected" : "Chat History",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        // delete selection button
        _isSelectionMode
            ? FilledButton(
                onPressed: _confirmDelete,
                style: ButtonStyle(
                  backgroundColor: WidgetStateColor.fromMap({
                    WidgetState.any: Colors.red.shade700,
                  }),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 12.0,
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

        const SizedBox(width: 8),
        // select all icon
        IconButton(
          icon: Icon(_isSelectionMode ? Icons.close : Icons.edit_note),
          color: Colors.white,
          onPressed: () {
            setState(() {
              _isSelectionMode = !_isSelectionMode;
            });
          },
        ),
      ],
    );
  }
}
