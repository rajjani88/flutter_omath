import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/daily_challenge_controller.dart';
import 'package:flutter_omath/controllers/calculate_numbers_contoller.dart';
import 'package:flutter_omath/screens/calculate_numbers/calculate_numbers_screens.dart';
import 'package:get/get.dart';

class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyChallengeController controller = Get.find();

    return Obx(() {
      bool isCompleted = controller.isTodayCompleted.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCompleted
                ? [Colors.green.shade400, Colors.green.shade700]
                : [Colors.orange.shade400, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "🔥 Daily Challenge",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Streak: ${controller.currentStreak.value}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isCompleted)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Completed for Today",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to game with Seed
                    int seed = controller.getDailySeed();
                    Get.to(() => CalculateNumbersScreen(
                          selectedMode: OperationMode.auto,
                          isDailyChallenge: true,
                          dailySeed: seed,
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Play Now",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
