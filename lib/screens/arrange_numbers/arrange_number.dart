import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/arrange_number_contoller.dart';
import 'package:flutter_omath/models/order_type.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:get/get.dart';

class ArrangeNumber extends StatefulWidget {
  const ArrangeNumber({super.key});

  @override
  State<ArrangeNumber> createState() => _ArrangeNumberState();
}

class _ArrangeNumberState extends State<ArrangeNumber> {
  ArrangeNumberController controller = Get.find();
  @override
  void initState() {
    super.initState();
    controller.generateNumbers(
      8,
    );
    controller.startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    controller.disposeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mAppBlue,
      body: Obx(
        () => controller.gameOver.value
            ? buildGameOver()
            : Column(
                children: [
                  const SizedBox(
                    height: 56,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'logo',
                          child: Image.asset(
                            imgNumber,
                            height: 56,
                            width: 56,
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        const Text(
                          'Arrange Numbers',
                          style: TextStyle(
                              color: mWhitecolor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(14),
                    child: Divider(
                      color: mWhitecolor,
                    ),
                  ),
                  Obx(() => Text("Level: ${controller.currentLevel.value}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: mWhitecolor))),
                  const SizedBox(height: 20),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Time Left: ",
                              style:
                                  TextStyle(fontSize: 14, color: mWhitecolor)),
                          const SizedBox(
                            width: 10,
                          ),
                          Text("${controller.remainingTime.value}s",
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: mRedColor,
                                  fontWeight: FontWeight.w800))
                        ],
                      )),
                  // Show ASC/DSC
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Arrange the numbers in",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: mWhitecolor,
                            ),
                          ),
                          Text(
                            " ${controller.currentOrder.value == OrderType.asc ? "ASCENDING" : "DESCENDING"} ",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: mWhitecolor,
                            ),
                          ),
                          Text(
                            "order",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: mWhitecolor,
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 20),
                  // Center slots (empty boxes)
                  Obx(() => Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: controller.userSelection
                                .map((number) => Container(
                                      width: 60,
                                      height: 60,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: mWhitecolor, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                        color: number != null
                                            ? Colors.blue
                                            : Colors.transparent,
                                      ),
                                      child: Text(
                                        number?.toString() ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),

                  // Number buttons (pool)
                  Obx(() => Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: controller.numberPool
                                .map((num) => GestureDetector(
                                      onTap: () => controller.selectNumber(num),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          num.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      )),
                  const SizedBox(height: 30),
                ],
              ),
      ),
    );
  }

  Widget buildGameOver() {
    Get.find<AdsController>().showRewardedAd();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("⏱️ Time's up!", style: TextStyle(fontSize: 24)),
          Text("Score: ${controller.currentLevel}",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              controller.generateNumbers(
                8,
              );
              controller.startTimer();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }
}
