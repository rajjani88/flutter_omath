import 'package:flutter_omath/controllers/arrange_number_contoller.dart';
import 'package:get/get.dart';

Future<void> init() async {
  Get.lazyPut(
    () => ArrangeNumberController(),
  );
}
