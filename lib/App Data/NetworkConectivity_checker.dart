import 'package:get/get.dart';
import '../NetworkController/Controller.dart';


class DependencyInjection {
  static void init() {
    Get.put(NetworkController(), permanent: true);
  }
}
