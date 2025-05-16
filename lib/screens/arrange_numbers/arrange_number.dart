import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/arrange_number_contoller.dart';
import 'package:flutter_omath/models/order_type.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arrange Numbers')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => Text("Level: ${controller.currentLevel.value}",
              style: TextStyle(fontSize: 18))),
          const SizedBox(height: 20),
          Obx(() => Text("Time Left: ${controller.remainingTime.value}s",
              style: TextStyle(fontSize: 18, color: Colors.red))),
          // Show ASC/DSC
          Obx(() => Text(
                "Arrange the numbers in ${controller.currentOrder.value == OrderType.asc ? "ASCENDING" : "DESCENDING"} order",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              )),
          const SizedBox(height: 20),
          // Center slots (empty boxes)
          Obx(() => Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: controller.userSelection
                    .map((num) => Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(8),
                            color:
                                num != null ? Colors.blue : Colors.transparent,
                          ),
                          child: Text(
                            num?.toString() ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ))
                    .toList(),
              )),
          const SizedBox(height: 40),

          // Number buttons (pool)
          Obx(() => Wrap(
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
                              borderRadius: BorderRadius.circular(8),
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
              )),
          const SizedBox(height: 30),

          // Reset Button
          ElevatedButton(
            onPressed: controller.resetGame,
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
