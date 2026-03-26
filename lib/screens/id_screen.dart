import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/identity_controller.dart';

class IdScreen extends StatefulWidget {
  const IdScreen({super.key});

  @override
  State<IdScreen> createState() => _IdScreenState();
}

class _IdScreenState extends State<IdScreen> {
  late IdentityController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(IdentityController());
  }

  @override
  void dispose() {
    Get.delete<IdentityController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
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
        title: Obx(
          () => Column(
            children: [
              Text(
                'Room #${controller.roomCode}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19.53,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${controller.memberCount} members',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 13.67,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827).withOpacity(.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'For this room, you are',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      controller.identity.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 58.59,

                        letterSpacing: 0,
                        foreground: Paint()
                          ..shader =
                              const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFDE047), Color(0xFFA3E635)],
                              ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'This is your anonymous identifier, visible only to others in this room.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 13.67,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 35),
                child: Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 59.25,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.acknowledge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC6F135),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: const Color(
                          0xFFC6F135,
                        ).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.63),
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
                              'Acknowledge and continue',
                              style: TextStyle(
                                fontSize: 17.58,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
