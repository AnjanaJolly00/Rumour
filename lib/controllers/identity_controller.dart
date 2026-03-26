import 'package:get/get.dart';
import 'package:rumour/models/user_id_model.dart';
import 'package:rumour/repo/room_repo.dart';
import 'package:rumour/routes/app_pages.dart';

class IdentityController extends GetxController {
  final RoomRepository _roomRepository = RoomRepository();

  final isLoading = false.obs;
  late String roomCode;
  late UserIdModel identity;
  final memberCount = 0.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    roomCode = args['roomCode'];
    identity = args['identity'];

    _roomRepository.roomStream(roomCode).listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        memberCount.value = data['memberCount'] ?? 0;
      }
    });
  }

  Future<void> acknowledge() async {
    isLoading.value = true;

    try {
      await _roomRepository.incrementMemberCount(roomCode);

      Get.offAndToNamed(
        AppRoutes.chat,
        arguments: {'roomCode': roomCode, 'identity': identity},
      );
    } catch (e) {
      Get.offAndToNamed(
        AppRoutes.chat,
        arguments: {'roomCode': roomCode, 'identity': identity},
      );
    } finally {
      isLoading.value = false;
    }
  }
}
