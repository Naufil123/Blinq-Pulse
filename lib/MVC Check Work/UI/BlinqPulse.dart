import 'package:flutter/material.dart';

import '../Controller/HealthController.dart';
import 'package:get/get.dart';

class BlinqPulseHome extends StatelessWidget {

  final controller = Get.put(HealthController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Blinq Pulse")),

      body: Obx(() => GridView.builder(
        itemCount: controller.portals.length,
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),

        itemBuilder: (_, index) {

          final service = controller.portals[index];

          return Obx(() => Card(
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [

                Text(service.name),

                if(service.loading.value)
                  CircularProgressIndicator()
                else
                  Row(
                    children: [

                      Icon(
                        service.apiUp.value
                            ? Icons.cloud
                            : Icons.cloud_off,
                        color: service.apiUp.value
                            ? Colors.green
                            : Colors.red,
                      ),

                      Icon(
                        service.dbUp.value
                            ? Icons.storage
                            : Icons.storage_outlined,
                        color: service.dbUp.value
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  )
              ],
            ),
          ));
        },
      )),
    );
  }
}
