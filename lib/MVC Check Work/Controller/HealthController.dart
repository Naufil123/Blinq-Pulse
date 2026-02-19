import 'dart:async';
import 'package:get/get.dart';
import '../../DashBoard/AuthData.dart';
import '../Service/ServiceModel.dart';



class HealthController extends GetxController {

  RxBool isLive = true.obs;
  Timer? timer;

  var portals = <ServiceModel>[].obs;
  var apis = <ServiceModel>[].obs;
  var databases = <ServiceModel>[].obs;
  var alerts = <ServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initServices();
    startTimer();
  }

  void initServices() {
    portals.assignAll([
      ServiceModel(name: "Admin Portal"),
      ServiceModel(name: "Merchant Portal"),
      ServiceModel(name: "IPG Portal"),
    ]);

    apis.assignAll([
      ServiceModel(name: "Mobile API"),
      ServiceModel(name: "Payment API"),
    ]);

    databases.assignAll([
      ServiceModel(name: "Core DB"),
      ServiceModel(name: "Mobile DB"),
    ]);
  }

  void startTimer() {
    fetchAll();

    timer = Timer.periodic(
      Duration(seconds: 60),
          (_) => fetchAll(),
    );
  }

  Future<void> fetchAll() async {

    /// ⭐ Parallel calls (VERY FAST)
    await Future.wait([
      fetchPortalHealth(),
      fetchApiHealth(),
      fetchDbHealth(),
    ]);
  }

  Future<void> fetchPortalHealth() async {

    for (var service in portals) {

      service.loading.value = true;

      final result = await AuthData.checkDomainStatus("URL");

      bool up = result != null;

      service.apiUp.value = up;
      service.dbUp.value = up;
      service.loading.value = false;
    }
  }

  Future<void> fetchApiHealth() async {
    for (var service in apis) {

      service.loading.value = true;

      final result = await AuthData.checkDomainStatus("URL");

      service.apiUp.value = result != null;
      service.dbUp.value = true;

      service.loading.value = false;
    }
  }

  Future<void> fetchDbHealth() async {
    for (var service in databases) {

      service.loading.value = true;

      final result = await AuthData.checkDatabaseHealth("DB_URL");

      service.dbUp.value = result ?? false;
      service.apiUp.value = true;

      service.loading.value = false;
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
