import 'dart:async';
import 'dart:convert';
import  'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import '../FireBase/PushNotification.dart';


class AuthData{
  static const String siteUrl = "https://pulseapi.blinq.pk/api/blinq/health";
  static const String dbHealth = '$siteUrl/database?environment=';
  static const String domainStatus = '$siteUrl/domainstatus?domainUrl=';
  static const String OnelinkInquiryAPiLink='https://pulseapi.blinq.pk/api/blinq/health/onelink-inquiry';
  static const String OnelinkPaymentAPiLink='https://pulseapi.blinq.pk/api/blinq/health/onelink-payment';
  static const  timer = 150;
  String? fcmToken;

// ########################################### Api Keys ##################################
  static const String apiKeyStaging = "S905TAcU9bD29e48rnCJAsQpwQAqBnZd52OhDZt3BBIvQQQq2j5Uv0wXhstzWfno4jugilAOMXZy2dOzcMlCxw7oU2qAgSZP+G6N3AxD3Lw=";
  static const String apiKeyLive = "S905TAcU9bD29e48rnCJAsQpwQAqBnZd52OhDZt3jhewqkjhkbJHJBH99Wfno4jugilAOMXZy2dOzcMlCxw7oU2qAgSZP+G6N3AxD3Lw=";
// ########################################### Api Keys ##################################


  static Future<List<dynamic>?> checkDomainStatus(String domainUrl) async {
    final url = Uri.parse(domainUrl);
    final request = http.Request('GET', url);

    try {
      final response = await request.send().timeout(
        const Duration(seconds: timer),
        onTimeout: () {
          throw TimeoutException("Domain request timed out");
        },
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> decoded = jsonDecode(responseBody);

        // Extract health_Status list
        final List<dynamic> dataList = decoded['health_Status'] ?? [];
        if (dataList.isEmpty) {
          return [
            {
              "component": "Domain",
              "status": "DOWN",
              "message": "No data received (empty health_Status list)",
              "timestamp": DateTime.now().toIso8601String(),
            }
          ];
        }

        if (kDebugMode) {
          for (var item in dataList) {
            final component = item['component'] ?? 'Unknown';
            final status = item['status']?.toString().toUpperCase() ?? 'UNKNOWN';
            final message = item['message'] ?? '';

            print('Component: $component');
            print('Status: $status');
            print('Message: $message');
            print('-------------------------');
          }
        }

        return dataList;
      } else {
        if (kDebugMode) {
          print('Domain request failed: ${response.statusCode} - ${response.reasonPhrase}');
        }
      }
    } on TimeoutException catch (_) {
      if (kDebugMode) {
        print("Domain request exceeded 15 seconds — marking as DOWN");
      }
      return [
        {
          "component": "Domain",
          "status": "DOWN",
          "message": "Timeout after 15 seconds",
          "timestamp": DateTime.now().toIso8601String(),
        }
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Domain request exception: $e');
      }
    }

    return null;
  }



  static Future<bool?> checkDatabaseHealth(String environment) async {
    final url = Uri.parse('$dbHealth$environment');
    final request = http.Request('GET', url);

    try {

      final response = await request.send().timeout(
        const Duration(seconds: timer),
        onTimeout: () {
          throw TimeoutException("Database health check timed out");
        },
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);

        if (kDebugMode) {
          print('Response Body:\n$data');
        }

        final status
        = data['databaseStatus']?.toString().toUpperCase();
        return status == "CONNECTED";
      } else {
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}');
          print('Reason: ${response.reasonPhrase}');
        }
      }
    } on TimeoutException catch (_) {
      if (kDebugMode) {
        print("Database request exceeded 15 seconds — marking as DOWN");
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
    }

    return null;
  }



  static Future<Map<String, dynamic>?> getAlerts(String domainUrl, String duration,String enviorment) async {
    final selectedApiKey = enviorment.toLowerCase() == 'live'
        ? apiKeyLive
        : apiKeyStaging;
    final url = Uri.parse(domainUrl);

    final headers = {
      'api_key': selectedApiKey,
      'param_time_filter': duration,
    };

    final request = http.Request('GET', url);
    request.headers.addAll(headers);

    try {
      final response = await request.send().timeout(
        const Duration(seconds: timer),
        onTimeout: () {
          throw TimeoutException("API request timed out");
        },
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decoded = jsonDecode(responseBody);

        if (kDebugMode) {
          print("Decoded response: $decoded");
        }

        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is List) {
          return { "data": decoded, "Whatsapp-Service-Status": "OK" };
        }
      }
      else {
        if (kDebugMode) {
          print('Request failed: ${response.statusCode} - ${response.reasonPhrase}');
        }
      }
    } on TimeoutException catch (_) {
      if (kDebugMode) {
        print("Alerts API request exceeded $timer seconds — marking as DOWN");
      }
      return {
        "Whatsapp-Service-Status": "DOWN",
        "message": "Timeout after $timer seconds",
        "timestamp": DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Alerts request exception: $e');
      }
    }

    return null;
  }







  static Future<List<dynamic>> fetchOneLinkInquiryHealth(String domainUrl,
      String timeFilter) async {
    final uri = Uri.parse('$domainUrl?TimeFilter=$timeFilter');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded;
        } else {
          // Wrap single object in a list
          return [decoded];
        }
      } else {
        throw Exception(
            'API request failed: ${response.statusCode} ${response
                .reasonPhrase}');
      }
    } catch (e) {
      throw Exception('OneLink API error: $e');
    }
  }

  static Future<List<dynamic>> fetchOneLinkPaymentHealth(String domainUrl,
      String timeFilter) async {
    final uri = Uri.parse('$domainUrl?TimeFilter=$timeFilter');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded;
        } else {
          return [decoded];
        }
      } else {
        throw Exception(
            'API request failed: ${response.statusCode} ${response
                .reasonPhrase}');
      }
    } catch (e) {
      throw Exception('OneLink API error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getDomainHealth(
      String domainUrl) async {

    try {
      final uri = Uri.parse(
          'https://pulseapi.blinq.pk/api/blinq/health/check?domainUrl=$domainUrl');

      final request = http.Request('GET', uri);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {

        final responseString =
        await response.stream.bytesToString();

        final decodedData =
        jsonDecode(responseString) as Map<String, dynamic>;

        return decodedData;
      } else {
        print("API Error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Exception in getDomainHealth: $e");
      return null;
    }
  }

   static Future<Map<String, dynamic>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      return {
        "device_name": androidInfo.model,
        "device_type": androidInfo.brand,
        "device_os": androidInfo.version.release,
        "device_serial_number": androidInfo.id,
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      return {
        "device_name": iosInfo.name,
        "device_type": iosInfo.model,
        "device_os": iosInfo.systemVersion,
        "device_serial_number": iosInfo.identifierForVendor,
      };
    }

    return {};
  }

  static Future<Map<String, dynamic>?> registerDevice({
    required String username,
    required String secretPin,
  }) async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> deviceData = {};

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          "device_name": androidInfo.model,
          "device_type": androidInfo.brand,
          "device_os": androidInfo.version.release,
          "device_serial_number": androidInfo.id,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          "device_name": iosInfo.name,
          "device_type": iosInfo.model,
          "device_os": iosInfo.systemVersion,
          "device_serial_number": iosInfo.identifierForVendor,
        };
      }

      final fcmToken = await FirebaseApi().initNotifications();
      if (fcmToken == null) {
        print("FCM Token is null");
        return null;
      }

      final url = Uri.parse(
          'https://staging-mobileapi.blinq.pk/api/v2/mobile/pulse/user-device/firebase-id/insert');
      final headers = {
        'api_key': apiKeyStaging,
        'Content-Type': 'application/json',
      };

      final body = {
        "mobile_device_id": fcmToken,
        "device_name": deviceData["device_name"],
        "device_type": deviceData["device_type"],
        "device_os": deviceData["device_os"],
        "device_serial_number": deviceData["device_serial_number"],
        "username": username,
        "secret_pin": secretPin,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        return responseBody;
      } else {
        print("HTTP error: ${response.statusCode}");
        print(response.body);
        return null;
      }
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

  // example getDeviceInfo
 /* static Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      "device_name": "emulator",
      "device_type": "Google sdk_gphone64_x86_64",
      "device_os": "14",
      "device_serial_number": "ABCDEFGH",
    };
  }*/
}

