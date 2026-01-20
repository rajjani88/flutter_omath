import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:flutter_omath/widgets/glass_back_button.dart';
import 'package:flutter_omath/widgets/glass_card.dart';
import 'package:flutter_omath/widgets/juicy_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_omath/widgets/streak_components.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final UserController userController = Get.find<UserController>();
  final TextEditingController nameController = TextEditingController();

  // Username validation state
  Timer? _debounce;
  final Rx<bool?> isUsernameValid = Rx<bool?>(null);
  final RxBool isCheckingUsername = false.obs;

  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    nameController.text = userController.odUsername.value;

    // Bounce Animation for Avatar (slight floating effect)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    _bounceController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty ||
        value.trim() == userController.odUsername.value) {
      isUsernameValid.value = null;
      isCheckingUsername.value = false;
      return;
    }

    isCheckingUsername.value = true;
    isUsernameValid.value = null;

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      // Logic from provided React code: < 3 chars check
      if (value.trim().length < 3) {
        isCheckingUsername.value = false;
        isUsernameValid.value = false;
        return;
      }

      final result = await userController.isUsernameAvailable(value);
      isCheckingUsername.value = false;
      if (result == "OFFLINE") {
        isUsernameValid.value = null;
      } else {
        isUsernameValid.value = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Theme base color from React: #2d1b4e
    const bgColor = Color(0xFF2d1b4e);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile",
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  GlassBackButton(onTap: () => Navigator.of(context).pop()),
                ],
              ),

              const SizedBox(height: 30),

              // 1. Avatar Section
              GlassCard(
                borderRadius: 40,
                padding: const EdgeInsets.all(24),
                // Gradient: Purple to Transparent (vertical)
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "CHOOSE AVATAR",
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Current Avatar (Large + Animated)
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 112,
                        height: 112,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC084FC), Color(0xFFEC4899)],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC084FC).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF1a0b2e),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Obx(() {
                              final id = userController.avatarId.value;
                              return Image.asset(
                                SupabaseConfig.getAvatarPath(id),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person,
                                      color: Colors.white, size: 40);
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Avatar Grid
                    Center(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: List.generate(5, (index) {
                          return Obx(() {
                            final isSelected =
                                userController.avatarId.value == index;
                            return GestureDetector(
                              onTap: () => userController.updateAvatar(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.2),
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 8)
                                        ]
                                      : [],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    SupabaseConfig.getAvatarPath(index),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.person,
                                          color: Colors.white, size: 24);
                                    },
                                  ),
                                ),
                              ),
                            );
                          });
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Username Section
              GlassCard(
                borderRadius: 32,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "USERNAME",
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Input Field
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextField(
                                controller: nameController,
                                onChanged: _onUsernameChanged,
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.2),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFC084FC),
                                    ),
                                  ),
                                ),
                              ),
                              // Validation Icon
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Obx(() {
                                  if (isCheckingUsername.value) {
                                    return const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white54),
                                    );
                                  }
                                  if (isUsernameValid.value == true) {
                                    return const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.greenAccent);
                                  }
                                  if (isUsernameValid.value == false) {
                                    return const Icon(Icons.cancel_rounded,
                                        color: Colors.redAccent);
                                  }
                                  return const SizedBox.shrink();
                                }),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Save Button
                        Obx(() {
                          final isValid = isUsernameValid.value == true;
                          return GestureDetector(
                            onTap: isValid
                                ? () {
                                    userController
                                        .updateUsername(nameController.text);
                                    // Reset validation state after save
                                    isUsernameValid.value = null;
                                  }
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: isValid
                                    ? Colors.green
                                    : Colors.white.withOpacity(0.05),
                                boxShadow: isValid
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: isValid
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                                size: 28,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Status Text
                    Obx(() {
                      if (isUsernameValid.value == true) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            "✓ Username available",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                        );
                      }
                      if (isUsernameValid.value == false) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            "✗ Username taken or too short",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Daily Streak (New Infinite Design)
              Obx(() => StreakProfileCard(
                    streakCount: userController.loginStreak.value,
                  )),

              const SizedBox(height: 32),

              // 4. Share Button (JuicyButton)
              JuicyButton(
                color: const Color(0xFF38BDF8), // Sky Blue
                icon: Icons.share_rounded,
                label: "Share & Earn 50 Coins",
                onTap: () => userController.shareApp(),
              ),

              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
