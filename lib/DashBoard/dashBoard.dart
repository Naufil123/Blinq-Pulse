import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'AuthData.dart';
import 'package:flutter/cupertino.dart';



class BlinqPulseHome extends StatefulWidget {
  @override
  _BlinqPulseHomeState createState() => _BlinqPulseHomeState();

}

class _BlinqPulseHomeState extends State<BlinqPulseHome>  {
  bool isLive = true;
  Timer? _statusRefreshTimer;

  Map<String, List<Map<String, dynamic>>> serviceStatusLive = {
    "Portal_Live": [
      {"name": "Admin Portal",
        "up": "dowm" ,
        "loading": true},
      {"name": "Merchant Portal","up": "dowm" ,
        "loading": true},
      {"name": "IPG Portal", "up": "dowm" ,
        "loading": true},
      {"name": "Utility Portal", "up": "dowm" ,
        "loading": true},
    ],
    "API_Live": [
      {"name": "Mobile Api", "up": "dowm"},
      {"name": "Merchant Api", "up": "dowm"},
      {"name": "Payment Api", "up": "dowm"},
    ],
    "Database_Live": [
      {
        "name": "Blinq_Core_DB",
        "connected": "disconnected",
        "loading": true
      },
      {
        "name": "Blinq_Mobile_DB",
        "connected": "disconnected",
        "loading": true
      },
    ],
    "Alerts_Live":[
    {"name":"Whatsapp","ok":"down"},
    {"name":"SMS","ok":"down"},
    {"name":"Email","ok":"down"},
    {"name":"Push Notification","ok":"down"}
  ],
  };
  final Map<String, String> sectionTitles = {
    "Portal_Live": "Portals (Live)",
    "API_Live": "APIs (Live)",
    "Database_Live": "Databases (Live)",
    "Portal_Staging": "Portals (Staging)",
    "API_Staging": "APIs (Staging)",
    "Database_Staging": "Databases (Staging)",
  };

  Map<String, List<Map<String, dynamic>>> serviceStatusStaging = {
    "Portal_Staging": [
      {"name": "Admin Portal",
        "up": "dowm" ,
        "loading": true},
      {"name": "Merchant Portal","up": "dowm" ,
        "loading": true},
      {"name": "IPG Portal", "up": "dowm" ,
        "loading": true},
      {"name": "Utility Portal", "up": "dowm" ,
        "loading": true},
    ],
    "API_Staging": [
      {"name": "Mobile Api", "up": "down"},
      {"name": "Merchant Api", "up": "down"},
      {"name": "Payment Api", "up": "down"},
    ],
    "Database_Staging": [
      {
        "name": "Blinq_Core_Db",
        "connected": "disconnected",
        "loading": true
      },
      {
        "name": "Blinq_Mobile_Db",
        "connected": "disconnected",
        "loading": true
      },
    ],
    "Alerts_Staging":[
      {"name":"Whatsapp","ok":"down"},
      {"name":"SMS","ok":"down"},
      {"name":"Email","ok":"down"},
      {"name":"Push Notification","ok":"down"}
    ],
  };

  bool hasDownService(Map<String, List<Map<String, dynamic>>> envStatus) {
    for (var category in envStatus.values) {
      for (var service in category) {
        final status = (service['up'] ?? service['connected'])?.toString().toLowerCase();
        if (status == 'down' || status == 'disconnected') {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();


    if (isLive) {
      callAllDBHealthStatuses_live();
      CallDomainStatus_live();
      CallApiHealthStatus_live();
      CallAlertsStatus_live();
    }
    else{
      callAllDBHealthStatuses_staging();
      CallDomainStatus_staging();
      CallApiHealthStatus_Staging();
      CallAlertsStatus_Staging();
    }

    _statusRefreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (isLive) {
        callAllDBHealthStatuses_live();
         CallDomainStatus_live();
        CallApiHealthStatus_live();
        CallAlertsStatus_live();
      }
      else{
        callAllDBHealthStatuses_staging();
        CallDomainStatus_staging();
        CallApiHealthStatus_Staging();
        CallAlertsStatus_Staging();
      }
    });
  }

  @override
  void dispose() {
    _statusRefreshTimer?.cancel();
    super.dispose();
  }


  Future<void> callAllDBHealthStatuses_staging() async {
    callDBHealthStatus("Blinq_staging_CoreDb", "Blinq_Core_Db","Staging");
    callDBHealthStatus("Blinq_staging_MobileDb", "Blinq_Mobile_Db","Staging");
  }

  Future<void> callAllDBHealthStatuses_live() async {
    callDBHealthStatus("Blinq_Live_CoreDb", "Blinq_Core_DB","Live");
    callDBHealthStatus("Blinq_Live_MobileDb", "Blinq_Mobile_DB","Live");
  }


  Future<void> CallDomainStatus_live() async {

    CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=AdminPortalLive", "Admin Portal","Live");
    CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MerchantPortalLive", "Merchant Portal","Live");
    CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=IpgPortalLive", "IPG Portal","Live");
    CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=UtilityPortalLive", "Utility Portal","Live");
  }


  Future<void> CallDomainStatus_staging() async {
  CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=AdminPortalStaging", "Admin Portal","Staging");
    CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=IpgPortalStaging", "IPG Portal","Staging");
     CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MerchantPortalStaging", "Merchant Portal","Staging");
     CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=UtilityPortalStaging", "Utility Portal","Staging");
  }

  Future<void> CallApiHealthStatus_live() async {
    CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MerchantApilive", "Merchant Api","Live");
     CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=PaymentApilive", "Payment Api","Live");
     CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MobileApiLive", "Mobile Api","Live");
  }
  Future<void> CallApiHealthStatus_Staging() async {
   CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MerchantApiStaging", "Merchant Api","Staging");
   CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=PaymentApiStaging", "Payment Api","Staging");
   CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MobileApiStaging ", "Mobile Api","Staging");
  }
  Future<void> CallAlertsStatus_live() async {
    callAltertsStatus("https://mobileapi.blinq.pk/api/blinq/health/whatsapp/stats","Whatsapp","Live","15min");
    callAltertsStatus("https://mobileapi.blinq.pk/api/blinq/health/sms/stats","SMS","Live","15min");
    callAltertsStatus("https://mobileapi.blinq.pk/api/blinq/health/email/stats","Email","Live","15min");
    callAltertsStatus("https://mobileapi.blinq.pk/api/blinq/health/pushnotification/stats","Push Notification","Live","15min");
  }
  Future<void> CallAlertsStatus_Staging() async {
    callAltertsStatus("https://staging-mobileapi.blinq.pk/api/blinq/health/whatsapp/stats","Whatsapp","Staging","15min");
    callAltertsStatus("https://staging-mobileapi.blinq.pk/api/blinq/health/sms/stats","SMS","Staging","15min");
    callAltertsStatus("https://staging-mobileapi.blinq.pk/api/blinq/health/email/stats","Email","Staging","15min");
    callAltertsStatus("https://staging-mobileapi.blinq.pk/api/blinq/health/pushnotification/stats","Push Notification","Staging","15min");
  }

  Future<void> callDBHealthStatus(String db_url, String serviceName,enviorment) async {
    List<dynamic>? portalServices;

    if (enviorment == "Staging") {
      portalServices = serviceStatusStaging["Database_Staging"];
    }
    else if (enviorment == "Live") {
      portalServices = serviceStatusLive["Database_Live"];
    }

    if (portalServices != null) {
      for (var portal in portalServices) {
        if (portal["name"] == serviceName) {
          portal["loading"] = true;
        }
      }
      setState(() {});
    }

    final status = await AuthData.checkDatabaseHealth(db_url);
    bool apiStatusUp = true;
    bool dbStatusUp = true;
    setState(() {
      if (portalServices != null) {
        for (var portal in portalServices) {
          if (portal["name"] == serviceName) {
            portal["apiUp"] = apiStatusUp ? "up" : "down";
            portal["dbUp"] = (status != null && status) ? "up" : "down";
            portal["loading"] = false;
          }
        }
      }

      if (portalServices != null) {
        for (var db in portalServices) {
          if (db["name"] == serviceName) {
            db["connected"] = (status != null && status) ? "connected" : "disconnected";
            db["loading"] = false;
          }
        }
      }
    });
  }
  Future<void> CallDomainStatus(String domainUrl, String serviceName, enviorment) async {
    List<dynamic>? portalServices;

    if (enviorment == "Staging") {
      portalServices = serviceStatusStaging["Portal_Staging"];
    } else if (enviorment == "Live") {
      portalServices = serviceStatusLive["Portal_Live"];
    }

    // Set loading true
    if (portalServices != null) {
      for (var portal in portalServices) {
        if (portal["name"] == serviceName) {
          portal["loading"] = true;
        }
      }
      setState(() {});
    }

    final domainStatusList = await AuthData.checkDomainStatus(domainUrl);

    if (domainStatusList != null) {
      final List<String> apiComponents = ["Utility Portal", "IPG Portal", "Merchant Portal", "Admin Portal"];
      final List<String> dbComponents = ["Blinq Database", "Mobile Database"];
      bool apiStatusUp = true;
      bool dbStatusUp = true;


      if (domainStatusList.isEmpty ||
          (domainStatusList.length == 1 && domainStatusList.first['status'] == 'DOWN')) {
        apiStatusUp = false;
        dbStatusUp = false;
      } else {
        for (var item in domainStatusList) {
          final component = item['component'] ?? 'Unknown';
          final status = item['status']?.toString().toUpperCase() ?? 'UNKNOWN';
          print("Component: $component | Status: $status");

          if (apiComponents.contains(component)) {
            if (status != "UP") apiStatusUp = false;
          }
          if (dbComponents.contains(component)) {
            if (status != "UP") dbStatusUp = false;
          }
        }
      }

      // Update the portal service
      if (portalServices != null) {
        for (var portal in portalServices) {
          if (portal["name"] == serviceName) {
            portal["apiUp"] = apiStatusUp ? "up" : "down";
            portal["dbUp"] = dbStatusUp ? "up" : "down";
            portal["loading"] = false;
          }
        }
      }

      setState(() {});
    }
  }


 /* Future<void> CallDomainStatus(String domainUrl, String serviceName,enviorment) async {
    List<dynamic>? portalServices;
    if (enviorment == "Staging") {
      portalServices = serviceStatusStaging["Portal_Staging"];
    }
    else if (enviorment == "Live") {
      portalServices = serviceStatusLive["Portal_Live"];
    }

    if (portalServices != null) {
      for (var portal in portalServices) {
        if (portal["name"] == serviceName) {
          portal["loading"] = true;
        }
      }
      setState(() {});
    }

    final domainStatusList = await AuthData.checkDomainStatus(domainUrl);

    if (domainStatusList != null) {

      final List<String> apiComponents = ["Utility Portal","IPG Portal","Merchant Portal","Admin Portal"];
      final List<String> dbComponents = ["Blinq Database", "Mobile Database"];
      bool apiStatusUp = true;
      bool dbStatusUp = true;
      for (var item in domainStatusList) {
        final component = item['component'] ?? 'Unknown';
        final status = item['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        print("Component: $component | Status: $status");
        if (apiComponents.contains(component)) {
          if (status != "UP") apiStatusUp = false;
        }
        if (dbComponents.contains(component)) {
          if (status != "UP") dbStatusUp = false;
        }
      }
      if (portalServices != null) {
        for (var portal in portalServices) {
          if (portal["name"] == serviceName) {
            portal["apiUp"] = apiStatusUp ? "up" : "down";
            portal["dbUp"] = dbStatusUp ? "up" : "down";
            portal["loading"] = false;
          }
        }
      }
      setState(() {});

    }
  }
*/
  Future<void> CallApiHealthStatus(
      String domainUrl, String serviceName, String enviorment) async {
    List<dynamic>? portalServices;
    if (enviorment == "Staging") {
      portalServices = serviceStatusStaging["API_Staging"];
    }
    else if (enviorment == "Live") {
      portalServices = serviceStatusLive["API_Live"];
    }
    if (portalServices != null) {
      for (var portal in portalServices) {
        if (portal["name"] == serviceName) {
          portal["loading"] = true;
        }
      }
      setState(() {});
    }

    final domainStatusList = await AuthData.checkDomainStatus(domainUrl);

    if (domainStatusList != null) {

        final List<String> apiComponents = ["Mobile API","Payment Api","Merchant Api"];
        final List<String> dbComponents = ["Blinq Database", "Mobile Database"];
        bool apiStatusUp = true;
        bool dbStatusUp = true;
        for (var item in domainStatusList) {
          final component = item['component'] ?? 'Unknown';
          final status = item['status']?.toString().toUpperCase() ?? 'UNKNOWN';
          print("Component: $component | Status: $status");
          if (apiComponents.contains(component)) {
            if (status != "UP") apiStatusUp = false;
          }
          if (dbComponents.contains(component)) {
            if (status != "UP") dbStatusUp = false;
          }
        }
        if (portalServices != null) {
          for (var portal in portalServices) {
            if (portal["name"] == serviceName) {
              portal["apiUp"] = apiStatusUp ? "up" : "down";
              portal["dbUp"] = dbStatusUp ? "up" : "down";
              portal["loading"] = false;
            }
          }
        }
        setState(() {});

    }
  }
  Future<void> callAltertsStatus(
      String domainUrl,
      String serviceName,
      String enviorment,
      String duration,
      ) async {
    List<dynamic>? portalServices;
    if (enviorment == "Staging") {
      portalServices = serviceStatusStaging["Alerts_Staging"];
    } else if (enviorment == "Live") {
      portalServices = serviceStatusLive["Alerts_Live"];
    }

    if (portalServices != null) {
      for (var portal in portalServices) {
        if (portal["name"] == serviceName) {
          portal["loading"] = true;
          portal["details"] = null; // clear old data
        }
      }
      setState(() {});
    }

    final domainStatusList = await AuthData.getAlerts(domainUrl, duration, enviorment);
    final dataList = domainStatusList?["data"];
   if (dataList is List && dataList.isNotEmpty) {
      final item = dataList[0]; // or [1] if you want the second
      final status = item['Whatsapp-Service-Status']?.toString().toUpperCase() ?? "UNKNOWN";
      bool serviceUp = status == "OK";
      print("Service is up? $serviceUp");


    if (portalServices != null) {
        for (var portal in portalServices) {
          if (portal["name"] == serviceName) {
            portal["dbUp"] = "1";
            portal["apiUp"] = serviceUp ? "up" : "down";
            portal["loading"] = false;
            portal["details"] = item;
          }
        }
      }
      setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
      final serviceStatus = isLive ? serviceStatusLive : serviceStatusStaging;
      final liveHasIssue = hasDownService(serviceStatusLive);
      final stagingHasIssue = hasDownService(serviceStatusStaging);

      return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, // Aligns to the left
            children: [
              Image.asset(
                'assets/images/blinq-logoo.png',
                height: 40,
              ),
            ],
          ),
        ),

        actions: [
          Row(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text('Staging', style: TextStyle(color: Colors.black87)),
                  ),
                  if (stagingHasIssue)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.red,
                      ),
                    ),
                ],
              ),
              Switch(
                value: isLive,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.orange,
                onChanged: (val) {
                  setState(() => isLive = val);
                  if (isLive) {
                    callAllDBHealthStatuses_live();
                    CallDomainStatus_live();
                    CallApiHealthStatus_live();
                    CallAlertsStatus_live();
                  } else {
                    callAllDBHealthStatuses_staging();
                    CallDomainStatus_staging();
                    CallApiHealthStatus_Staging();
                    CallAlertsStatus_Staging();
                  }
                },
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text('Live', style: TextStyle(color: Colors.black87)),
                  ),
                  if (liveHasIssue)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.red,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Divider(
                color: Colors.orange.shade700,
                thickness: 2.5,
                height: 6,
                indent: 16,
                endIndent: 16,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  serviceStatus.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 8.0),
                          child: Text(
                            sectionTitles[entry.key] ?? entry.key,
                            // entry.key,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: entry.value.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5,
                          ),
                            itemBuilder: (context, index) {
                              final service = entry.value[index];
                              final name = service['name'];

                              // Get the API/DB status from your portalServices
                              final apiStatus = service['apiUp']?.toString().toLowerCase();
                              final dbStatus = service['dbUp']?.toString().toLowerCase();
                              final isLoading = service['loading'] == true;

                              // final apiUp = apiStatus == 'up';
                              final dbUp = dbStatus == 'up' || dbStatus == '1';
                              final apiUp = apiStatus == 'up' || dbStatus == '1';


                              return InkWell(
                                onTap: () {
                                  final details = service['details'];
                                  showDialog(

                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Title
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      name,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    // Orange close button
                                                    IconButton(
                                                      icon: const Icon(Icons.close, color: Colors.orange),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  height: 2,
                                                  width: double.infinity,
                                                  color: Colors.orange,
                                                ),

                                                const SizedBox(height: 12),
                                                // Details Section
                                                if (details != null) ...[
                                                  const Text(
                                                    "Details:",
                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  ...details.entries.map(
                                                        (e) => Padding(
                                                      padding: const EdgeInsets.only(bottom: 4.0),
                                                      child: Text("${e.key}: ${e.value}"),
                                                    ),
                                                  ),
                                                ] else
                                                  const Text(
                                                    "No extra information found.",
                                                    style: TextStyle(color: Colors.grey),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },

                                child:Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                shadowColor: Colors.grey.shade400,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      if (isLoading)
                                        SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
                                          ),
                                        )
                                      else
                                        Row(
                                          children: [
                                            if (apiUp && dbUp)
                                              ...[
                                                Icon(Icons.cloud_off, size: 20, color: Colors.green),
                                                const SizedBox(width: 4),
                                                Icon(Icons.storage_rounded, size: 20, color: Colors.green),
                                              ],

                                            if (!apiUp && dbUp)...[
                                              Icon(Icons.cloud_off, size: 20, color: Colors.red),
                                            const SizedBox(width: 4),
                                            Icon(Icons.storage_rounded, size: 20, color: Colors.green),
],
                                            if (apiUp && !dbUp)...[
                                              Icon(Icons.cloud_off, size: 20, color: Colors.green),
                                              const SizedBox(width: 4),
                                              Icon(Icons.storage_rounded, size: 20, color: Colors.red),
                                            ],

                                            if (!apiUp && !dbUp) ...[
                                              Icon(Icons.cloud_off, size: 20, color: Colors.red),
                                              const SizedBox(width: 4),
                                              Icon(Icons.storage_rounded, size: 20, color: Colors.red),
                                            ],
                                            if (apiUp=="1" && dbUp) ...[
                                              Icon(Icons.storage_rounded, size: 20, color: Colors.green),
                                            ],
                               if (apiUp=="1" && !dbUp) ...[
                                              Icon(Icons.storage_rounded, size: 20, color: Colors.red),
                                            ],
                                            if (apiUp && dbUp=="1") ...[
                                              Icon(Icons.cloud_off, size: 20, color: Colors.green),
                                            ],
                               if (!apiUp && dbUp=="1") ...[
                                              Icon(Icons.cloud_off, size: 20, color: Colors.red),
                                            ],
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                  ),
                              );
                            }

                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
