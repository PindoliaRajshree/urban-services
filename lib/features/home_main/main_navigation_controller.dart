import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 2.obs; // Default to Home (center)

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
