import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/calculate_numbers_contoller.dart';
import 'package:get/get.dart';

class CalculateNumbersScreen extends StatefulWidget {
  final OperationMode selectedMode;

  const CalculateNumbersScreen({super.key, required this.selectedMode});

  @override
  State<CalculateNumbersScreen> createState() => _CalculateNumbersScreenState();
}

class _CalculateNumbersScreenState extends State<CalculateNumbersScreen> {
  final controller = Get.find<CalculateNumbersController>();

  @override
  Widget build(BuildContext context) {
    controller.startGame(widget.selectedMode);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculate Numbers"),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() => controller.isGamOver.value
          ? buildGameOver()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Level: ${controller.level.value}",
                          style: const TextStyle(fontSize: 18)),
                      Text("Time: ${controller.timer.value}s",
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Question Area
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        controller.question.value,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Answer Display
                  Text(controller.userAnswer.value,
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 20),

                  // Keypad
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      if (index == 9) {
                        return buildButton("Reset", controller.resetInput);
                      } else if (index == 10) {
                        return buildButton("0", () => controller.addInput("0"));
                      } else if (index == 11) {
                        return buildButton("OK", controller.submitAnswer);
                      } else {
                        return buildButton("${index + 1}",
                            () => controller.addInput("${index + 1}"));
                      }
                    },
                  )
                ],
              ),
            )),
    );
  }

  Widget buildGameOver() {
    Get.find<AdsController>().showRewardedAd();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("⏱️ Time's up!", style: TextStyle(fontSize: 24)),
          Text("Score: ${controller.level}",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              controller.startGame(OperationMode.auto);
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(fontSize: 22, color: Colors.white)),
        ),
      ),
    );
  }
}
