import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppData {
// ########################################### Api Urls ##################################
  static const String siteUrl = "https://pulseapi.blinq.pk/api/blinq/health";
  static const String dbHealth = '$siteUrl/database?environment=';
  static const String domianStatus = '$siteUrl/domainstatus?domainUrl=';
  static const  timmer = 15;

// ########################################### Api Urls ##################################


// ########################################### Api Keys ##################################
  static const String Api_key_Staging = "S905TAcU9bD29e48rnCJAsQpwQAqBnZd52OhDZt3BBIvQQQq2j5Uv0wXhstzWfno4jugilAOMXZy2dOzcMlCxw7oU2qAgSZP+G6N3AxD3Lw=";
  static const String Api_key_Live = "S905TAcU9bD29e48rnCJAsQpwQAqBnZd52OhDZt3jhewqkjhkbJHJBH99Wfno4jugilAOMXZy2dOzcMlCxw7oU2qAgSZP+G6N3AxD3Lw=";

// ########################################### Api Keys ##################################

  static Future<bool?> checkDatabaseHealth(String environment) async {
    final url = Uri.parse('$dbHealth$environment');
    final request = http.Request('GET', url);

    try {
      // ⏳ Timeout after 15 seconds
      final response = await request.send().timeout(
        const Duration(seconds: timmer),
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

        final status = data['databaseStatus']?.toString().toUpperCase();
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


  static Future<List<dynamic>?> checkDomainStatus(String domainUrl) async {
    final url = Uri.parse(domainUrl);
    final request = http.Request('GET', url);

    try {
      final response = await request.send().timeout(
        const Duration(seconds: timmer),
        onTimeout: () {
          throw TimeoutException("Domain request timed out");
        },
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final List<dynamic> dataList = jsonDecode(responseBody);

        if (kDebugMode) {
          for (var item in dataList) {
            final component = item['component'] ?? 'Unknown';
            final status = item['status']?.toString().toUpperCase() ?? 'UNKNOWN';
            final message = item['message'] ?? '';
            final timestamp = item['timestamp'] ?? '';

            print('Component: $component');
            print('Status: $status');
            print('Message: $message');
            print('Timestamp: $timestamp');
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

  static Future<List<dynamic>?> getApiHealth(String domainUrl,
      String enviorment,
      String serviceName,) async {
    final selectedApiKey = enviorment.toLowerCase() == 'live' &&
        serviceName.toLowerCase() == "mobile api"
        ? Api_key_Live
        : Api_key_Staging;

    final url = Uri.parse(domainUrl);

    final headers = {
      'api_key': selectedApiKey,
    };

    final request = http.MultipartRequest('GET', url);
    request.fields.addAll({'api_key': selectedApiKey});
    request.headers.addAll(headers);

    try {

      final response = await request.send().timeout(
        const Duration(seconds: timmer),
        onTimeout: () {
          throw TimeoutException("API request timed out");
        },
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final List<dynamic> dataList = jsonDecode(responseBody);

        if (kDebugMode) {
          for (var item in dataList) {
            print('Component: ${item['component'] ?? 'Unknown'}');
            print('Status: ${item['status']?.toString().toUpperCase() ??
                'UNKNOWN'}');
            print('Message: ${item['message'] ?? ''}');
            print('Timestamp: ${item['timestamp'] ?? ''}');
            print('-------------------------');
          }
        }

        return dataList;
      } else {
        if (kDebugMode) {
          print('Domain request failed: ${response.statusCode} - ${response
              .reasonPhrase}');
        }
      }
    } on TimeoutException catch (_) {
      if (kDebugMode) {
        print("API request exceeded 15 seconds — marking as DOWN");
      }
      return [
        {
          "component": serviceName,
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


  static Future<Map<String, dynamic>?> getAlerts(String domainUrl, String duration,String enviorment) async {
    final selectedApiKey = enviorment.toLowerCase() == 'live'
        ? Api_key_Live
        : Api_key_Staging;

    final url = Uri.parse(domainUrl);

    final headers = {
      'api_key': selectedApiKey,
      'param_time_filter': duration,
    };

    final request = http.Request('GET', url);
    request.headers.addAll(headers);

    try {
      final response = await request.send().timeout(
        const Duration(seconds: timmer),
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
        print("Alerts API request exceeded $timmer seconds — marking as DOWN");
      }
      return {
        "Whatsapp-Service-Status": "DOWN",
        "message": "Timeout after $timmer seconds",
        "timestamp": DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Alerts request exception: $e');
      }
    }

    return null;
  }



}