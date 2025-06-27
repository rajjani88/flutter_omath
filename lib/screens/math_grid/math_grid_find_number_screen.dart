import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/math_grid_puzzle_controller.dart';
import 'package:get/get.dart';

class MathGridFindNumber extends StatefulWidget {
  const MathGridFindNumber({super.key});

  @override
  State<MathGridFindNumber> createState() => _MathGridFindNumberState();
}

class _MathGridFindNumberState extends State<MathGridFindNumber> {
  final controller = Get.find<MathGridPuzzleController>();

  @override
  void initState() {
    super.initState();
    controller.startGame();
  }

  @override
  void dispose() {
    super.dispose();
    controller.gameDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Math Grid Puzzle")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildGameHeader(controller),
              const SizedBox(height: 20),
              _buildQuestion(controller),
              const SizedBox(height: 20),
              _buildAnswerGrid(controller),
            ],
          ),
        ));
  }

  Widget _buildGameHeader(MathGridPuzzleController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Text("⏰ ${controller.timeLeft.value}s",
            style: const TextStyle(fontSize: 20))),
        Obx(() => Text("📈 Lv ${controller.level.value}",
            style: const TextStyle(fontSize: 20))),
      ],
    );
  }

  Widget _buildQuestion(MathGridPuzzleController controller) {
    return Obx(() => Text(
          controller.currentQuestion.value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ));
  }

  // Widget _buildAnswerGrid(MathGridPuzzleController controller) {
  Widget _buildAnswerGrid(MathGridPuzzleController controller) {
    return Expanded(
      child: Obx(() {
        // final items = controller.gridItems;

        return GridView.builder(
          itemCount: controller.answerOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (_, index) {
            final item = controller.answerOptions[index];
            return ElevatedButton(
              onPressed: () => controller.onAnswerSelected(item),
              child: Text('$item', style: const TextStyle(fontSize: 24)),
            );
          },
        );
      }),
    );
  }
}
