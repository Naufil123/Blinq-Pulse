import 'package:get/get.dart';


class ServiceModel {
  final String name;
  RxBool apiUp = false.obs;
  RxBool dbUp = false.obs;
  RxBool loading = true.obs;
  RxMap<String, dynamic>? details = RxMap();

  ServiceModel({required this.name});
}
