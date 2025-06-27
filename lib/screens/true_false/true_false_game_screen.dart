import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/controllers/true_false_controller.dart';
import 'package:get/get.dart';

class TrueFalseGame extends StatefulWidget {
  const TrueFalseGame({super.key});

  @override
  State<TrueFalseGame> createState() => _TrueFalseGameState();
}

class _TrueFalseGameState extends State<TrueFalseGame> {
  AdsController adsController = Get.find();
  InAppPurchaseController purchaseController = Get.find();
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrueFalseGameController());

    return Scaffold(
      appBar: AppBar(title: const Text("True or False?")),
      body: Obx(() {
        if (controller.isGameOver.value) {
          Get.find<AdsController>().showInterstitialAd();
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("⏱️ Time's up!", style: TextStyle(fontSize: 24)),
                Text("Score: ${controller.score}",
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (!purchaseController.isPro.value) {
                      adsController.showInterstitialAd();
                    }
                    controller.resetGame();
                  },
                  child: const Text("Play Again"),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text("⏰ ${controller.timer}s",
                      style: const TextStyle(fontSize: 20))),
                  Obx(() => Text("🏆 ${controller.score}",
                      style: const TextStyle(fontSize: 20))),
                  Obx(() => Text("📈 Lv ${controller.level}",
                      style: const TextStyle(fontSize: 20))),
                ],
              ),
              const Spacer(),
              // Question
              Obx(() => Text(
                    controller.question.value,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  )),
              const Spacer(),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.onAnswer(true),
                    icon: const Icon(Icons.check, size: 28),
                    label: const Text("True", style: TextStyle(fontSize: 20)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => controller.onAnswer(false),
                    icon: const Icon(Icons.close, size: 28),
                    label: const Text("False", style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        );
      }),
    );
  }
}
