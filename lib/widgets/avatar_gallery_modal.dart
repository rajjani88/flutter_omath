import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:flutter_omath/screens/go_pro/go_pro_screen.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AvatarGalleryModal extends StatelessWidget {
  const AvatarGalleryModal({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    // final InAppPurchaseController iapController =
    //     Get.find<InAppPurchaseController>();

    return Container(
      height: Get.height * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFF1a0b2e).withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Choose Avatar",
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: Obx(() {
              final isPremium = true;
              final currentAvatarId = userController.avatarId.value;

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                itemCount: 26, // Total avatars 0-25
                itemBuilder: (context, index) {
                  final bool isLocked = index > 4 && !isPremium;
                  final bool isSelected = currentAvatarId == index;

                  return GestureDetector(
                    onTap: () {
                      userController.updateAvatar(index);
                      Get.back();
                    },
                    child: Stack(
                      children: [
                        // Avatar Thumbnail
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.black.withOpacity(0.2),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : Border.all(color: Colors.white10, width: 1),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              SupabaseConfig.getAvatarPath(index),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person,
                                    color: Colors.white24, size: 30);
                              },
                            ),
                          ),
                        ),

                        // Selected Indicator
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
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

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AvatarGalleryModal(),
    );
  }
}
