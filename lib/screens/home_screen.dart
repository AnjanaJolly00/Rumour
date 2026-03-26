import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rumour/widgets/room_code_input.dart';
import '../../controllers/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
  }

  @override
  void dispose() {
    Get.delete<HomeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Container(
                  height: 70,
                  width: 70,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: SvgPicture.asset('assets/key_logo.svg'),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Join A Room',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        height: 36 / 30,
                        letterSpacing: 0,
                        color: const Color(0xFFFAFAFA),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Enter the code to join the anon chat room',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 24 / 16,
                        letterSpacing: 0,
                        color: const Color(0xFFA1A1AA),
                      ),
                    ),

                    const SizedBox(height: 40),

                    RoomCodeInput(
                      controller: controller.roomCodeController,
                      focusNode: controller.roomCodeFocusNode,
                      onCompleted: (code) => controller.joinRoom(),
                    ),

                    const SizedBox(height: 12),

                    // Error message
                    Obx(
                      () => controller.errorMessage.value.isNotEmpty
                          ? Text(
                              controller.errorMessage.value,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 24),

                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.joinRoom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC6F135),
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: const Color(
                              0xFFC6F135,
                            ).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Join Room',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade800)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade800)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.createNewRoom,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC6F135),
                            side: const BorderSide(
                              color: Color(0xFFC6F135),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create New Room',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Obx(() {
                    //   if (controller.recentRooms.isEmpty) {
                    //     return const SizedBox.shrink();
                    //   }

                    //   return Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Padding(
                    //         padding: const EdgeInsets.symmetric(vertical: 16),
                    //         child: const Text(
                    //           'Recent Rooms',
                    //           style: TextStyle(
                    //             color: Colors.grey,
                    //             fontSize: 13,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ),

                    //       const SizedBox(height: 12),

                    // ListView.separated(
                    //   padding: EdgeInsets.only(bottom: 15),
                    //   shrinkWrap: true,
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   itemCount: controller.recentRooms.length,
                    //   separatorBuilder: (_, __) =>
                    //       const SizedBox(height: 8),
                    //   itemBuilder: (context, index) {
                    //     final roomCode = controller.recentRooms[index];
                    //     return GestureDetector(
                    //       onTap: () {
                    //         controller.roomCodeController.text = roomCode;
                    //         controller.joinRoom();
                    //       },
                    //       child: Container(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 16,
                    //           vertical: 14,
                    //         ),
                    //         decoration: BoxDecoration(
                    //           color: const Color(0xFF1E1E1E),
                    //           borderRadius: BorderRadius.circular(12),
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             const Icon(
                    //               Icons.meeting_room_outlined,
                    //               color: Color(0xFFC6F135),
                    //               size: 18,
                    //             ),
                    //             const SizedBox(width: 12),
                    //             Text(
                    //               'Room #$roomCode',
                    //               style: const TextStyle(
                    //                 color: Colors.white,
                    //                 fontSize: 14,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //             const Spacer(),
                    //             const Icon(
                    //               Icons.arrow_forward_ios,
                    //               color: Colors.grey,
                    //               size: 14,
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                  //   );
                  // }),
                  // ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
