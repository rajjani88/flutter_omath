import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/math_maze_controller.dart';
import 'package:get/get.dart';

class MathMazeView extends StatelessWidget {
  final MathMazeController controller = Get.put(MathMazeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Math Maze")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Level: ${controller.level.value}",
                        style: const TextStyle(fontSize: 18)),
                    Text(
                        "Moves: ${controller.movesMade}/${controller.moveLimit}",
                        style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Start: '),
                    Text("${controller.startNumber}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Target: '),
                    Text("${controller.targetNumber}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Reach target Number in only 4 Moves.',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600))
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      "Current: ${controller.currentNumber}",
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: 9,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final row = index ~/ 3;
                      final col = index % 3;
                      final operation = controller.grid[row][col];
                      return buildButton(
                        operation,
                        () {
                          controller.applyOperation(operation);
                        },
                      );
                      // return ElevatedButton(
                      //   onPressed: () => controller.applyOperation(operation),
                      //   child: Text(operation,
                      //       style: const TextStyle(fontSize: 20)),
                      // );
                    },
                  ),
                ),
              ],
            )),
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
