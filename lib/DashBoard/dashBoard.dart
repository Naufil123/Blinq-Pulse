import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../OneLink/OneLinkInquiryUI.dart';
import 'AuthData.dart';
import 'package:flutter/cupertino.dart';
import '../OneLink/OnelinkPaymentUI.dart';
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
      {"name": "Merchant Portal","up": "down" ,
        "loading": true},
      {"name": "IPG Portal", "up": "down" ,
        "loading": true},
      {"name": "Utility Portal", "up": "down" ,
        "loading": true},
    ],
    "API_Live": [
      {"name": "Mobile Api", "up": "down"},
      {"name": "Merchant Api", "up": "down"},
      {"name": "Payment Api", "up": "down"},
      // {"name": "OneLink Api", "up": "down"},
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
    "Alerts_Live": "Alerts (Live)",
    "Alerts_Staging": "Alerts (Staging)",
  };

  Map<String, List<Map<String, dynamic>>> serviceStatusStaging = {
    "Portal_Staging": [
      {"name": "Admin Portal",
        "up": "down" ,
        "loading": true},
      {"name": "Merchant Portal","up": "down" ,
        "loading": true},
      {"name": "IPG Portal", "up": "down" ,
        "loading": true},
      {"name": "Utility Portal", "up": "down" ,
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
        if (service['loading'] == true) continue;

        final apiStatus = service['apiUp']?.toString().toLowerCase() ?? 'unknown';
        final dbStatus = service['dbUp']?.toString().toLowerCase() ?? 'unknown';

        if (apiStatus == 'down' || dbStatus == 'down' || apiStatus == 'disconnected' || dbStatus == 'disconnected') {
          return true;
        }
      }
    }
    return false;
  }

  List<String> inquiryStatuses = [];
  List<String> paymentStatuses = [];

  Future<void> fetchOneLinkAllStatuses() async {
    try {
      final dynamic inquiryRawData = await AuthData.fetchOneLinkInquiryHealth(
        AuthData.OnelinkInquiryAPiLink,
        selectedTimer,
      );
      if (inquiryRawData == null || inquiryRawData is! List || inquiryRawData.isEmpty) {
        throw Exception('Invalid OneLink Inquiry API response');
      }
      inquiryStatuses = []; // clear old data
      for (var item in inquiryRawData) {
        if (item is Map) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(item);
          final String status = data['serviceStatus']?.toString() ?? 'Unknown';
          inquiryStatuses.add(status);
        }
      }
      debugPrint('Inquiry Statuses: $inquiryStatuses');
      final dynamic paymentRawData = await AuthData.fetchOneLinkPaymentHealth(
          AuthData.OnelinkPaymentAPiLink,
        selectedTimer,
      );
      if (paymentRawData == null || paymentRawData is! List || paymentRawData.isEmpty) {
        throw Exception('Invalid OneLink Payment API response');
      }
      paymentStatuses = [];
      for (var item in paymentRawData) {
        if (item is Map) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(item);
          final String status = data['serviceStatus']?.toString() ?? 'Unknown';
          paymentStatuses.add(status);
        }
      }
      debugPrint('Payment Statuses: $paymentStatuses');
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching OneLink statuses: $e');
    }
  }
  Color getStatusColor(List<String> statuses) {
    if (statuses.isEmpty) return Colors.grey;
    final normalized =
    statuses.map((s) => s.trim().toUpperCase()).toList();
    if (normalized.contains('FAILURE')) {
      return Colors.red; // highest priority
    }
    if (normalized.contains('WARNING')) {
      return Colors.yellow;
    }
    if (normalized.every((s) => s == 'SUCCESS')) {
      return Colors.green;
    }
    return Colors.grey; // fallback
  }



  @override
  void initState() {
    super.initState();


    if (isLive) {
      callAllDBHealthStatuses_live();
      CallDomainStatus_live();
      CallApiHealthStatus_live();
      CallAlertsStatus_live();
      fetchOneLinkAllStatuses();
    }
    else{
      callAllDBHealthStatuses_staging();
      CallDomainStatus_staging();
      CallApiHealthStatus_Staging();
      CallAlertsStatus_Staging();
    }

    _statusRefreshTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      if (isLive) {
        callAllDBHealthStatuses_live();
        CallDomainStatus_live();
        CallApiHealthStatus_live();
        CallAlertsStatus_live();
        fetchOneLinkAllStatuses();

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

     CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=AdminPortalLive", "Admin Portal","Live","https://admin.blinq.pk:444");
    CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MerchantPortalLive", "Merchant Portal","Live","https://merchant.blinq.pk");
     CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=IpgPortalLive", "IPG Portal","Live","https://ipg.blinq.pk");
     CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=UtilityPortalLive", "Utility Portal","Live","https://tcsapp.blinq.pk");

  }
  Future<void> CallDomainStatus_staging() async {
    CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=AdminPortalStaging", "Admin Portal","Staging","https://staging-admin.blinq.pk");
    CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=IpgPortalStaging", "IPG Portal","Staging","https://staging-ipg.blinq.pk ");
    CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MerchantPortalStaging", "Merchant Portal","Staging","https://staging-merchant.blinq.pk");
    CallDomainStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=UtilityPortalStaging", "Utility Portal","Staging","https://staging-tcsapp.blinq.pk");
  }
  Future<void> CallApiHealthStatus_live() async {
    CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MerchantApilive", "Merchant Api","Live","https://api.blinq.pk");
    CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=PaymentApilive", "Payment Api","Live","https://payments.blinq.pk");
    CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MobileApiLive", "Mobile Api","Live","https://mobileapi.blinq.pk");
  }
  Future<void> CallApiHealthStatus_Staging() async {
    CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MerchantApiStaging", "Merchant Api","Staging","https://staging-api.blinq.pk");
    CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=PaymentApiStaging", "Payment Api","Staging","https://staging-payments.blinq.pk");
    CallApiHealthStatus("https://pulseapi.blinq.pk/api/blinq/healthcheck/status?reqname=MobileApiStaging ", "Mobile Api","Staging","https://staging-mobileapi.blinq.pk");
  }
  Future<void> CallAlertsStatus_live() async {
    callAltertsStatus("https://mobileapi.blinq.pk/api/blinq/health/whatsapp/stats","Whatsapp","Live",selectedTimer);
    callAltertsStatus("https://mobileapi.blinq.pk/api/blinq/health/sms/stats","SMS","Live",selectedTimer);
    callAltertsStatus("https://mobileapi.blinq.pk/api/blinq/health/email/stats","Email","Live",selectedTimer);
    callAltertsStatus("https://mobileapi.blinq.pk/api/blinq/health/pushnotification/stats","Push Notification","Live",selectedTimer);
  }
  Future<void> CallAlertsStatus_Staging() async {
    callAltertsStatus("https://staging-mobileapi.blinq.pk/api/blinq/health/whatsapp/stats","Whatsapp","Staging",selectedTimer);
    callAltertsStatus("https://staging-mobileapi.blinq.pk/api/blinq/health/sms/stats","SMS","Staging",selectedTimer);
    callAltertsStatus("https://staging-mobileapi.blinq.pk/api/blinq/health/email/stats","Email","Staging",selectedTimer);
    callAltertsStatus("https://staging-mobileapi.blinq.pk/api/blinq/health/pushnotification/stats","Push Notification","Staging",selectedTimer);
  }

  bool isOneLinkLoading = false;

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

  Future<void> CallDomainStatus(
      String domainUrl, String serviceName, String enviorment,String domainUrlInfo ) async {
    List<dynamic>? portalServices;
    if (enviorment == "Staging") {
      portalServices = serviceStatusStaging["Portal_Staging"];
    } else if (enviorment == "Live") {
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
    final domainStatusList =
    await AuthData.checkDomainStatus(domainUrl);
    bool apiStatusUp = true;
    bool dbStatusUp = true;
    if (domainStatusList == null || domainStatusList.isEmpty) {
      apiStatusUp = false;
      dbStatusUp = false;
    } else {
      for (var item in domainStatusList) {
        final status = item['status']?.toString().toUpperCase();
        if (status != "UP") {
          apiStatusUp = false;
          dbStatusUp = false;
        }
      }
    }
    final detailsData =
    await AuthData.getDomainHealth(domainUrlInfo);
    if (portalServices != null) {
      for (var portal in portalServices) {
        if (portal["name"] == serviceName) {
          portal["apiUp"] = apiStatusUp ? "up" : "down";
          portal["dbUp"] = dbStatusUp ? "up" : "down";
          portal["loading"] = false;
          portal["details"] = detailsData;
        }
      }
    }
    setState(() {});
  }
  Future<void> CallApiHealthStatus(
      String domainUrl,
      String serviceName,
      String enviorment,
      String domainUrlInfo) async {
    List<dynamic>? portalServices;
    if (enviorment == "Staging") {
      portalServices = serviceStatusStaging["API_Staging"];
    } else if (enviorment == "Live") {
      portalServices = serviceStatusLive["API_Live"];
    }
    if (portalServices != null) {
      for (var portal in portalServices) {
        if (portal["name"] == serviceName) {
          portal["loading"] = true;
          portal["details"] = null; // clear old
        }
      }
      setState(() {});
    }
    final domainStatusList =
    await AuthData.checkDomainStatus(domainUrl);
    if (domainStatusList != null) {
      final List<String> apiComponents = [
        "Mobile API",
        "Payment Api",
        "Merchant Api"
      ];
      final List<String> dbComponents = [
        "Blinq Database",
        "Mobile Database"
      ];
      bool apiStatusUp = true;
      bool dbStatusUp = true;
      for (var item in domainStatusList) {
        final component = item['component'] ?? 'Unknown';
        final status =
            item['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        if (apiComponents.contains(component)) {
          if (status != "UP") apiStatusUp = false;
        }
        if (dbComponents.contains(component)) {
          if (status != "UP") dbStatusUp = false;
        }
      }
      final healthDetails =
      await AuthData.getDomainHealth(domainUrlInfo);
      if (portalServices != null) {
        for (var portal in portalServices) {
          if (portal["name"] == serviceName) {
            portal["apiUp"] = apiStatusUp ? "up" : "down";
            portal["dbUp"] = dbStatusUp ? "up" : "down";
            portal["loading"] = false;
            portal["details"] = healthDetails;
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
      final item = dataList[0];
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

  final List<String> timerOptions = ['15min', '1hours', '24hours', '48hours'];
  String selectedTimer = '15min';

  @override
  Widget build(BuildContext context) {
    final serviceStatus = isLive ? serviceStatusLive : serviceStatusStaging;
    final liveHasIssue = hasDownService(serviceStatusLive);
    final stagingHasIssue = hasDownService(serviceStatusStaging);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, // Aligns to the left
            children: [
              Image.asset(
                'assets/images/BlinqPulse.png',
                height: 40,
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topLeft,
              colors: [
                Color(0xFF004080), // dark navy
                Color(0xFF3366CC), // medium blue
                Color(0xFF6699FF), // light blue
              ],
            ),
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
                    child: Text('Staging', style: TextStyle(color: Colors.white)),
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
                    fetchOneLinkAllStatuses();

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
                    child: Text('Live', style: TextStyle(color: Colors.white)),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF001F3F), // very dark navy
              Color(0xFF002A5C), // dark navy
              Color(0xFF003366), // medium navy
              Color(0xFF004080), // medium-light navy
              Color(0xFF3366CC), // soft blue
              Color(0xFF6699FF), // lighter blue // lighter navy
            ],
          ),
        ),
        child: Stack(
          children: [
        SafeArea(
          child: RefreshIndicator(
            color: Colors.orange,
            onRefresh: () async {
              if (isLive) {
                 callAllDBHealthStatuses_live();
                 CallDomainStatus_live();
                 CallApiHealthStatus_live();
                 CallAlertsStatus_live();
                 fetchOneLinkAllStatuses();

              } else {
                 callAllDBHealthStatuses_staging();
                 CallDomainStatus_staging();
                 CallApiHealthStatus_Staging();
                 CallAlertsStatus_Staging();
              }
              await Future.delayed(Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        if (isLive) ...[
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                isOneLinkLoading = true; // show loader
                              });
                              try {
                                final data = await AuthData.fetchOneLinkInquiryHealth(
                                    AuthData.OnelinkInquiryAPiLink, selectedTimer);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>OneLinkInquiryUI(
                                      oneLinkData: data,
                                      inquiryStatuses: inquiryStatuses,
                                      paymentStatuses: paymentStatuses,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                debugPrint('API call failed: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to load OneLink data')),
                                );
                              } finally {
                                setState(() {
                                  isOneLinkLoading = false;
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              side: BorderSide(color:  getStatusColor(inquiryStatuses)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '1Link Inquiry',
                              style: TextStyle(
                                color:  getStatusColor(inquiryStatuses),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
    ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                isOneLinkLoading = true; // show loader
                              });
                              try {
                                final data = await AuthData.fetchOneLinkPaymentHealth(
                                    AuthData.OnelinkPaymentAPiLink, selectedTimer);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OneLinkPaymentUI(
                                      oneLinkData: data,
                                      inquiryStatuses: inquiryStatuses,
                                      paymentStatuses: paymentStatuses,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                debugPrint('API call failed: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to load OneLink data')),
                                );
                              } finally {
                                setState(() {
                                  isOneLinkLoading = false; // hide loader
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              side: BorderSide(color:  getStatusColor(paymentStatuses),),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child:  Text(
                              '1Link Payment',
                              style: TextStyle(
                                color: getStatusColor(paymentStatuses),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    sectionTitles[entry.key] ?? entry.key,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  if (
                                  (isLive && entry.key == "Alerts_Live") ||
                                      (!isLive && entry.key == "Alerts_Staging")
                                  )
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedTimer,
                                          dropdownColor: const Color(0xFF004080),
                                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                          style: const TextStyle(color: Colors.white),
                                          items: timerOptions.map((option) {
                                            return DropdownMenuItem(
                                              value: option,
                                              child: Text(option),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() => selectedTimer = val);

                                              if (isLive) {
                                                CallAlertsStatus_live();
                                              } else {
                                                CallAlertsStatus_Staging();
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                ],
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
                                  final apiStatus = service['apiUp']?.toString().toLowerCase();
                                  final dbStatus = service['dbUp']?.toString().toLowerCase();
                                  final isLoading = service['loading'] == true;
                                  final dbUp = dbStatus == 'up' || dbStatus == '1';
                                  final apiUp = apiStatus == 'up' || dbStatus == '1';
                                  final details = service['details'];
                                  Widget card =Card(
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
                                                  ... [
                                                    Icon(Icons.cloud, size: 20, color: Colors.green),
                                                    const SizedBox(width: 4),
                                                    Icon(Icons.storage_rounded, size: 20, color: Colors.green),
                                                  ],
                                                if (!apiUp && dbUp)...[
                                                  Icon(Icons.cloud_off, size: 20, color: Colors.red),
                                                  const SizedBox(width: 4),
                                                  Icon(Icons.storage_rounded, size: 20, color: Colors.green),
                                                ],
                                                if (apiUp && !dbUp)...[
                                                  Icon(Icons.cloud, size: 20, color: Colors.green),
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
                                                  Icon(Icons.cloud, size: 20, color: Colors.green),
                                                ],
                                                if (!apiUp && dbUp=="1") ...[
                                                  Icon(Icons.cloud_off, size: 20, color: Colors.red),
                                                ],
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  );

                                  return details == null
                                      ? card // ❌ not clickable
                                      : InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF003366),
                                                    Color(0xFF0055AA),
                                                    Color(0xFF6699FF),
                                                  ],
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [

                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            name,
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(Icons.close, color: Colors.redAccent),
                                                            onPressed: () => Navigator.pop(context),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 8),

                                                      /// Divider
                                                      Container(
                                                        height: 2,
                                                        width: double.infinity,
                                                        color: Colors.white70,
                                                      ),

                                                      const SizedBox(height: 14),

                                                      /// Details Section
                                                      if (details != null) ...[
                                                        const Text(
                                                          "Details:",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 12),

                                                        /// Each line with margin like Urdu copy
                                                        ...details.entries.map(
                                                              (e) => Container(
                                                            margin: const EdgeInsets.symmetric(vertical: 6), // 👈 line spacing
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 6,
                                                              horizontal: 8,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white.withOpacity(0.12),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Text(
                                                              "${e.key}: ${e.value}",
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                height: 1.6, // 👈 line height (Urdu copy feel)
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ] else
                                                        const Text(
                                                          "No extra information found.",
                                                          style: TextStyle(color: Colors.white70),
                                                        ),
                                                    ],
                                                  ),
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
                                                    ... [
                                                      Icon(Icons.cloud, size: 20, color: Colors.green),
                                                      const SizedBox(width: 4),
                                                      Icon(Icons.storage_rounded, size: 20, color: Colors.green),
                                                    ],

                                                  if (!apiUp && dbUp)...[
                                                    Icon(Icons.cloud_off, size: 20, color: Colors.red),
                                                    const SizedBox(width: 4),
                                                    Icon(Icons.storage_rounded, size: 20, color: Colors.green),
                                                  ],
                                                  if (apiUp && !dbUp)...[
                                                    Icon(Icons.cloud, size: 20, color: Colors.green),
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
                                                    Icon(Icons.cloud, size: 20, color: Colors.green),
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
        ),
            if (isOneLinkLoading)
              Container(
                color: Colors.black54, // semi-transparent overlay
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
// *************************** Blinq Pulse Code Transfer to New Laptop *********************************
