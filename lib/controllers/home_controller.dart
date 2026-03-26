import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rumour/models/user_id_model.dart';
import 'package:rumour/repo/id_repo.dart';
import 'package:rumour/repo/room_repo.dart';
import 'package:rumour/routes/app_pages.dart';

class HomeController extends GetxController {
  final RoomRepository _roomRepository = RoomRepository();
  final IdentityRepository _identityRepository = IdentityRepository();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final roomCodeController = TextEditingController();
  final recentRooms = <String>[].obs;
  final roomCodeFocusNode = FocusNode();

  @override
  void onClose() {
    roomCodeController.dispose();
    roomCodeFocusNode.dispose();
    super.onClose();
  }

  Future<void> loadRecentRooms() async {
    final rooms = await _identityRepository.getRecentRooms();
    recentRooms.assignAll(rooms);
  }

  Future<void> joinRoom() async {
    final code = roomCodeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      errorMessage.value = 'Please enter a room code';
      return;
    }

    if (code.length < 4) {
      errorMessage.value = 'Room code is too short';
      return;
    }

    errorMessage.value = '';
    isLoading.value = true;

    try {
      final exists = await _roomRepository.roomExists(code);

      if (exists) {
        await _handleExistingRoom(code);
      } else {
        _showCreateRoomDialog(code);
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleExistingRoom(String code) async {
    final hasJoined = await _identityRepository.hasJoinedRoom(code);
    await _identityRepository.saveRecentRoom(code);
    await loadRecentRooms();

    if (hasJoined) {
      final identity = await _identityRepository.getOrCreateIdentity(code);
      _navigateToChat(code, identity);
    } else {
      final identity = await _identityRepository.getOrCreateIdentity(code);
      _navigateToIdentity(code, identity);
    }
  }

  Future<void> _createRoom(String code) async {
    isLoading.value = true;

    try {
      await _roomRepository.createRoom(code);
      final identity = await _identityRepository.getOrCreateIdentity(code);
      _navigateToIdentity(code, identity);
    } catch (e) {
      errorMessage.value = 'Failed to create room. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNewRoom() async {
    isLoading.value = true;
    try {
      final code = _roomRepository.generateRoomCode();
      await _roomRepository.createRoom(code);
      await _identityRepository.saveRecentRoom(code);
      await loadRecentRooms();
      final identity = await _identityRepository.getOrCreateIdentity(code);
      _navigateToIdentity(code, identity);
    } catch (e) {
      errorMessage.value = 'Failed to create room. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void _showCreateRoomDialog(String code) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Room Not Found',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Room "$code" does not exist. Would you like to create it?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();

              roomCodeController.clear();
              Future.delayed(
                const Duration(milliseconds: 200),
                () => roomCodeFocusNode.requestFocus(),
              );
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _createRoom(code);
            },
            child: const Text(
              'Create Room',
              style: TextStyle(color: Color(0xFFC6F135)),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToIdentity(String code, UserIdModel identity) {
    Get.toNamed(
      AppRoutes.identity,
      arguments: {'roomCode': code, 'identity': identity},
    );
  }

  void _navigateToChat(String code, UserIdModel identity) {
    Get.toNamed(
      AppRoutes.chat,
      arguments: {'roomCode': code, 'identity': identity},
    );
  }
}
