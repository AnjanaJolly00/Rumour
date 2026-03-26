import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumour/models/message_model.dart';
import 'package:rumour/models/user_id_model.dart';
import 'package:rumour/repo/message_repo.dart';
import 'package:rumour/repo/room_repo.dart';

class ChatController extends GetxController {
  final MessageRepository _messageRepository = MessageRepository();
  final RoomRepository _roomRepository = RoomRepository();

  final messages = <Message>[].obs;
  final isLoadingInitial = true.obs;
  final isLoadingMore = false.obs;
  final hasMoreMessages = true.obs;
  final memberCount = 0.obs;

  final messageController = TextEditingController();
  final scrollController = ScrollController();

  late String roomCode;
  late UserIdModel identity;

  DocumentSnapshot? _lastDocument;

  dynamic _messageStreamSubscription;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    roomCode = args['roomCode'];
    identity = args['identity'];

    _init();

    scrollController.addListener(_onScroll);
  }

  Future<void> _init() async {
    _listenToMemberCount();
    await _loadInitialMessages();
    _listenToNewMessages();
  }

  Future<void> _loadInitialMessages() async {
    try {
      isLoadingInitial.value = true;
      final fetched = await _messageRepository.loadInitialMessages(roomCode);

      if (fetched.isNotEmpty) {
        messages.assignAll(fetched);

        final rawDocs = await _getRawDocs();
        if (rawDocs.isNotEmpty) {
          _lastDocument = rawDocs.last;
        }
      }

      if (fetched.length < 20) {
        hasMoreMessages.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load messages',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingInitial.value = false;
    }
  }

  Future<List<DocumentSnapshot>> _getRawDocs() async {
    final snapshot = await _messageRepository
        .messagesRef(roomCode)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    return snapshot.docs;
  }

  void _listenToNewMessages() {
    _messageStreamSubscription = _messageRepository
        .newMessagesStream(roomCode: roomCode, after: DateTime.now())
        .listen((newMessages) {
          for (final msg in newMessages) {
            final exists = messages.any((m) => m.messageId == msg.messageId);
            if (!exists) {
              messages.add(msg);
              _scrollToBottom();
            }
          }
        });
  }

  void _listenToMemberCount() {
    _roomRepository.roomStream(roomCode).listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        memberCount.value = data['memberCount'] ?? 0;
      }
    });
  }

  Future<void> _loadMoreMessages() async {
    if (isLoadingMore.value || !hasMoreMessages.value) return;
    if (_lastDocument == null) return;

    try {
      isLoadingMore.value = true;

      final older = await _messageRepository.loadMoreMessages(
        roomCode: roomCode,
        lastDocument: _lastDocument!,
      );

      if (older.isEmpty || older.length < 20) {
        hasMoreMessages.value = false;
      }

      if (older.isNotEmpty) {
        final rawDocs = await _getOlderRawDocs();
        if (rawDocs.isNotEmpty) {
          _lastDocument = rawDocs.last;
        }

        messages.insertAll(0, older);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load more messages',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<List<DocumentSnapshot>> _getOlderRawDocs() async {
    final snapshot = await _messageRepository
        .messagesRef(roomCode)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(20)
        .get();
    return snapshot.docs;
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();

    try {
      await _messageRepository.sendMessage(
        roomCode: roomCode,
        senderId: identity.userId,
        senderName: identity.name,
        senderAvatar: identity.avatarUrl,
        text: text,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels == 0) {
      _loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<dynamic> get messagesWithSeparators {
    final result = <dynamic>[];
    DateTime? lastDate;

    for (final msg in messages) {
      final msgDate = msg.dateTime;
      if (msgDate != null) {
        final dateOnly = DateTime(msgDate.year, msgDate.month, msgDate.day);
        if (lastDate == null || lastDate != dateOnly) {
          result.add(dateOnly);
          lastDate = dateOnly;
        }
      }
      result.add(msg);
    }
    return result;
  }

  bool isMe(Message message) => message.senderId == identity.userId;

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    if (_messageStreamSubscription != null) {
      _messageStreamSubscription.cancel();
    }
    super.onClose();
  }
}
