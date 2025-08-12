import 'dart:async';
import 'package:flutter/material.dart';
import '../App Data/App_data.dart';

class BlinqPulseHome extends StatefulWidget {
  @override
  _BlinqPulseHomeState createState() => _BlinqPulseHomeState();

}

class _BlinqPulseHomeState extends State<BlinqPulseHome> {
  bool isLive = true;
  Timer? _statusRefreshTimer;

  Map<String, List<Map<String, dynamic>>> serviceStatusLive = {
    "Portal_Live": [
      {"name": "Admin Portal",
        "up": "dowm" ,
        "loading": true},
      {"name": "Merchant Portal","up": "dowm" ,
        "loading": true},
      {"name": "Market Place IPG", "up": "dowm" ,
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
    {"name":"whatsapp","ok":"down"},
    {"name":"sms","ok":"down"},
    {"name":"email","ok":"down"},
    {"name":"pushnotification","ok":"down"}
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
      {"name": "Market Place IPG", "up": "dowm" ,
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
      {"name":"whatsapp","ok":"down"},
      {"name":"sms","ok":"down"},
      {"name":"email","ok":"down"},
      {"name":"pushnotification","ok":"down"}
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
    CallDomainStatus("https://admin.blinq.pk:444/health/admin/portal/status", "Admin Portal","Live");
    CallDomainStatus("https://merchant.blinq.pk/health/merchant/portal/status", "Merchant Portal","Live");
    CallDomainStatus("https://ipg.blinq.pk//health/ipg/portal/status", "Market Place IPG","Live");
    CallDomainStatus("https://tcsapp.blinq.pk/health/utility/portal/status", "Utility Portal","Live");
  }


  Future<void> CallDomainStatus_staging() async {
    CallDomainStatus("https://staging-admin.blinq.pk/health/admin/portal/status", "Admin Portal","Staging");
    CallDomainStatus("https://staging-merchant.blinq.pk/health/merchant/portal/status", "Merchant Portal","Staging");
    CallDomainStatus("https://staging-ipg.blinq.pk//health/ipg/portal/status", "Market Place IPG","Staging");
    CallDomainStatus("https://staging-tcsapp.blinq.pk/health/utility/portal/status", "Utility Portal","Staging");

  }

  Future<void> CallApiHealthStatus_live() async {
    CallApiHealthStatus("https://api.blinq.pk/api/blinq/health/merchantapi", "Merchant Api","Live");
    CallApiHealthStatus("https://payments.blinq.pk/api/blinq/health/paymentapi", "Payment Api","Live");
    CallApiHealthStatus("https://mobileapi.blinq.pk/api/blinq/health/mobileapi", "Mobile Api","Live");
  }
  Future<void> CallApiHealthStatus_Staging() async {
    CallApiHealthStatus("https://staging-api.blinq.pk/api/blinq/health/merchantapi", "Merchant Api","Staging");
    CallApiHealthStatus("https://staging-payments.blinq.pk/api/blinq/health/paymentapi", "Payment Api","Staging");
    CallApiHealthStatus("https://staging-mobileapi.blinq.pk/api/blinq/health/mobileapi", "Mobile Api","Staging");
  }
  Future<void> CallAlertsStatus_live() async {
    callAltertsStatus("https://mobileapi.blinq.pk/api/blinq/health/whatsapp/stats","whatsapp","Live","15min");
  }
  Future<void> CallAlertsStatus_Staging() async {
    callAltertsStatus("https://staging-mobileapi.blinq.pk/api/blinq/health/whatsapp/stats","whatsapp","Staging","15min");
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

    final status = await AppData.checkDatabaseHealth(db_url);

    setState(() {
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

/*
  Future<void> callDBHealthStatus_Staging(String env, String serviceName) async {
    final dbServices = serviceStatusStaging["Database_Staging"];
    if (dbServices != null) {
      for (var db in dbServices) {
        if (db["name"] == serviceName) {
          db["loading"] = true;
        }
      }
      setState(() {});
    }

    final status = await AppData.checkDatabaseHealth(env);

    setState(() {
      if (dbServices != null) {
        for (var db in dbServices) {
          if (db["name"] == serviceName) {
            db["connected"] = (status != null && status) ? "connected" : "disconnected";
            db["loading"] = false;
          }
        }
      }
    });
  }
*/

  Future<void> CallDomainStatus(String domainUrl, String serviceName,enviorment) async {
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

    final domainStatusList = await AppData.checkDomainStatus(domainUrl);

    if (domainStatusList != null) {
      bool allUp = true;
      for (var item in domainStatusList) {
        final component = item['component'] ?? 'Unknown';
        final status = item['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        print("Component: $component | Status: $status");
        if (status != "UP") {
          allUp = false; // If any component is not UP, set false
        }
      }
      if (portalServices != null) {
        for (var portal in portalServices) {
          if (portal["name"] == serviceName) {
            portal["up"] = allUp ? "up" : "down";
            portal["loading"] = false;
          }
        }
      }

      setState(() {});
    } else {
      if (portalServices != null) {
        for (var portal in portalServices) {
          if (portal["name"] == serviceName) {
            portal["up"] = "down";
            portal["loading"] = false;
          }
        }
      }
      setState(() {});
    }
  }

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

    final domainStatusList = await AppData.getApiHealth(domainUrl,enviorment,serviceName);

    if (domainStatusList != null) {
      bool allUp = true;
      for (var item in domainStatusList) {
        final component = item['component'] ?? 'Unknown';
        final status = item['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        print("Component: $component | Status: $status");
        if (status != "UP") {
          allUp = false; // If any component is not UP, set false
        }
      }
      if (portalServices != null) {
        for (var portal in portalServices) {
          if (portal["name"] == serviceName) {
            portal["up"] = allUp ? "up" : "down";
            portal["loading"] = false;
          }
        }
      }

      else {
        if (portalServices != null) {
          for (var portal in portalServices) {
            if (portal["name"] == serviceName) {
              portal["up"] = "down";
              portal["loading"] = false;
            }
          }
        }
      }
    }

    setState(() {});
  }
  Future<void> callAltertsStatus(
      String domainUrl, String serviceName, String enviorment, String duration) async {

    List<dynamic>? portalServices;

    // Pick correct environment service list
    if (enviorment == "Staging") {
      portalServices = serviceStatusStaging["Alerts_Staging"];
    } else if (enviorment == "Live") {
      portalServices = serviceStatusLive["Alerts_Live"];
    }

    // Mark service as loading in UI
    if (portalServices != null) {
      for (var portal in portalServices) {
        if (portal["name"] == serviceName) {
          portal["loading"] = true;
        }
      }
      setState(() {});
    }

    // Call API
    final alertsData = await AppData.getAlerts(domainUrl, duration,enviorment);
    bool allUp = true;

    if (alertsData != null) {
       if (alertsData is Map<String, dynamic>) {
        alertsData.forEach((key, value) {
          print("$key: $value");
        });

        final serviceStatus = alertsData["Whatsapp-Service-Status"]
            ?.toString()
            .toUpperCase();
        if (serviceStatus != "OK") {
          allUp = false;
        }
      }
    } else {
      // If no data returned
      allUp = false;
      print("alertsData is null — marking as DOWN");
    }

    // Update UI
    if (portalServices != null) {
      for (var portal in portalServices) {
        if (portal["name"] == serviceName) {
          portal["up"] = allUp ? "up" : "down";
          portal["loading"] = false;
        }
      }
    }

    setState(() {});
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
                            childAspectRatio: 2.5, // adjust height/width
                          ),
                          itemBuilder: (context, index) {
                            final service = entry.value[index];
                            final name = service['name'];
                            final statusRaw = service['connected'] ?? service['up'] ?? '';
                            final status = statusRaw.toString().toLowerCase();
                            final isHealthy = status == 'up' || status == 'connected';
                            final isLoading = service['loading'] == true;

                            return Card(
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
                                    isLoading
                                        ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.orange.shade700),
                                      ),
                                    )
                                        : Row(
                                      children: [
                                       /* Text(
                                         *//* isHealthy ? "UP" : "DOWN",*//*
                                          style: TextStyle(
                                            color: isHealthy ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),*/
                                        const SizedBox(width: 4),
                                        Icon(
                                          isHealthy
                                              ? Icons.check_circle_outline
                                              : Icons.error_outline,
                                          size: 18,
                                          color: isHealthy ? Colors.green : Colors.red,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        /*  Column(
                          children: entry.value.map((service) {
                            final name = service['name'];
                            final statusRaw = service['connected'] ?? service['up'] ?? '';
                            final status = statusRaw.toString().toLowerCase();
                            final isHealthy = status == 'up' || status == 'connected';
                            final isLoading = service['loading'] == true;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                shadowColor: Colors.grey.shade400,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      isLoading
                                          ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.orange.shade700),
                                        ),
                                      )
                                          : Row(
                                        children: [
                                          Text(
                                            isHealthy ? "UP" : "DOWN",
                                            style: TextStyle(
                                              color: isHealthy
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            isHealthy
                                                ? Icons.check_circle_outline
                                                : Icons.error_outline,
                                            color: isHealthy
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),*/
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
