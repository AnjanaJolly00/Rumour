import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:rumour/models/message_model.dart';
import 'package:rumour/widgets/date_seperator.dart';
import 'package:rumour/widgets/message_bubble.dart';
import '../../controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController controller;

  @override
  @override
  void initState() {
    super.initState();
    controller = Get.put(ChatController());

    ever(controller.isLoadingInitial, (loading) {
      if (loading == false) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (controller.scrollController.hasClients) {
            controller.scrollController.jumpTo(
              controller.scrollController.position.maxScrollExtent,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    Get.delete<ChatController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(controller),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingInitial.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFC6F135)),
                );
              }

              if (controller.messages.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages yet.\nBe the first to say something!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                );
              }

              final items = controller.messagesWithSeparators;

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Obx(() {
                      if (controller.isLoadingMore.value) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFFC6F135),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    });
                  }

                  final item = items[index - 1];

                  if (item is DateTime) {
                    return DateSeparatorWidget(date: item);
                  }

                  if (item is Message) {
                    return MessageBubble(
                      message: item,
                      isMe: controller.isMe(item),
                    );
                  }

                  return const SizedBox.shrink();
                },
              );
            }),
          ),

          _buildInputBar(controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatController controller) {
    return AppBar(
      toolbarHeight: 60,
      backgroundColor: Colors.black,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),

        child: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: SvgPicture.asset('assets/back_button.svg'),
        ),
      ),
      title: Column(
        children: [
          Text(
            'Room #${controller.roomCode}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19.53,
              fontWeight: FontWeight.w700,
            ),
          ),
          Obx(
            () => Text(
              '${controller.memberCount.value} members',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13.67,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  // Input Bar
  Widget _buildInputBar(ChatController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey.shade900, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                  fontSize: 13.23,
                ),
                filled: true,
                fillColor: Color(0xFF111827).withOpacity(0.8),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => controller.sendMessage(),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: controller.sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFC6F135),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset('assets/sent_icon.svg'),
            ),
          ),
        ],
      ),
    );
  }
}
