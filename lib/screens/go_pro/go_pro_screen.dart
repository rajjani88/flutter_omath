import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/privacy_terms_row.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:flutter_omath/widgets/glass_back_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GoProScreen extends StatefulWidget {
  const GoProScreen({super.key});

  @override
  State<GoProScreen> createState() => _GoProScreenState();
}

class _GoProScreenState extends State<GoProScreen> {
  final InAppPurchaseController controller = Get.find<InAppPurchaseController>();

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassBackButton(onTap: () => Get.back()),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👑 ', style: TextStyle(fontSize: 14)),
                        Text(
                          'MATHWIZE PRO',
                          style: GoogleFonts.fredoka(
                            color: Colors.amberAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Paywall Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Animated Crown Header Icon
                    FadeInDown(
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                GameColors.primary,
                                GameColors.secondary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GameColors.primary.withOpacity(0.6),
                                blurRadius: 25,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                          child: Image.asset(
                            imgLogoTr,
                            height: 80,
                            width: 80,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Headline & Subtitle
                    FadeInDown(
                      delay: const Duration(milliseconds: 150),
                      child: Text(
                        'Unlock Your Full Potential',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FadeInDown(
                      delay: const Duration(milliseconds: 250),
                      child: Text(
                        'Unlimited Brain Training • Zero Ads • Infinite Power-Ups',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Feature Benefits Grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureRow('⚡ Unlimited Power-Ups', 'Freeze time, skip levels & instant hints', Icons.flash_on_rounded, GameColors.warning),
                          const Divider(color: Colors.white12, height: 20),
                          _buildFeatureRow('🏆 Exclusive Pro Badges & Avatars', 'Unlock all avatars & flex on leaderboard', Icons.workspace_premium_rounded, GameColors.secondary),
                          const Divider(color: Colors.white12, height: 20),
                          _buildFeatureRow('📅 Daily Challenge Replays', 'Never lose your streak, replay anytime', Icons.calendar_month_rounded, GameColors.success),
                          const Divider(color: Colors.white12, height: 20),
                          _buildFeatureRow('🛡️ 100% Pure Focus Experience', 'Zero interruptions, pure brain training', Icons.block_rounded, GameColors.danger),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Select Plan Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Your Plan:',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subscription Options
                    Obx(() => Column(
                      children: [
                        // Annual (Best Value Anchor)
                        _buildPlanCard(
                          plan: SubscriptionPlan.yearly,
                          title: 'Annual Pass',
                          subtitle: '7 Days Free Trial',
                          price: controller.priceYearly.value,
                          badgeText: 'BEST VALUE - SAVE 65%',
                          isBestValue: true,
                        ),
                        const SizedBox(height: 10),

                        // Monthly
                        _buildPlanCard(
                          plan: SubscriptionPlan.monthly,
                          title: 'Monthly Pass',
                          subtitle: '3 Days Free Trial',
                          price: controller.priceMonthly.value,
                        ),
                        const SizedBox(height: 10),

                        // Weekly
                        _buildPlanCard(
                          plan: SubscriptionPlan.weekly,
                          title: 'Weekly Pass',
                          subtitle: '3 Days Free Trial',
                          price: controller.priceWeekly.value,
                        ),
                        const SizedBox(height: 10),

                        // Lifetime
                        _buildPlanCard(
                          plan: SubscriptionPlan.lifetime,
                          title: 'Lifetime Unlimited',
                          subtitle: 'One-time payment • Pay once, play forever',
                          price: controller.priceLifetime.value,
                        ),
                      ],
                    )),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Fixed Bottom CTA Section
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: GameColors.panel,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const SizedBox(
                          height: 56,
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        );
                      }

                      String btnText = 'START 7-DAY FREE TRIAL';
                      if (controller.selectedPlan.value == SubscriptionPlan.weekly) {
                        btnText = 'START 3-DAY FREE TRIAL';
                      } else if (controller.selectedPlan.value == SubscriptionPlan.monthly) {
                        btnText = 'START 3-DAY FREE TRIAL';
                      } else if (controller.selectedPlan.value == SubscriptionPlan.lifetime) {
                        btnText = 'GET LIFETIME UNLIMITED';
                      }

                      return GameButton(
                        text: btnText,
                        color: GameColors.success,
                        shadowColor: GameColors.successShadow,
                        fontSize: 18,
                        height: 58,
                        onTap: () {
                          controller.purchaseSelectedPlan();
                        },
                      );
                    }),

                    const SizedBox(height: 12),

                    // Privacy, Terms & Restore Row
                    PrivacyTermsRow(
                      showRestore: true,
                      onRestoreClick: () {
                        controller.restorePurchases();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String title, String subtitle, IconData icon, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required String title,
    required String subtitle,
    required String price,
    String? badgeText,
    bool isBestValue = false,
  }) {
    final isSelected = controller.selectedPlan.value == plan;

    return GestureDetector(
      onTap: () {
        controller.selectedPlan.value = plan;
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? GameColors.primary.withOpacity(0.25)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (isBestValue ? Colors.amberAccent : GameColors.primary)
                    : Colors.white.withOpacity(0.12),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (isBestValue ? Colors.amber : GameColors.primary)
                            .withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? (isBestValue ? Colors.amberAccent : GameColors.primary)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? (isBestValue ? Colors.amberAccent : GameColors.primary)
                          : Colors.white38,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.black)
                      : null,
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.amberAccent : Colors.white60,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price display
                Text(
                  price,
                  style: GoogleFonts.fredoka(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Floating Badge for Best Value
          if (badgeText != null)
            Positioned(
              top: -10,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.fredoka(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
