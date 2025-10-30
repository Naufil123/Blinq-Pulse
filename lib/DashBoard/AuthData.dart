import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import  'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AuthData{
  static const String siteUrl = "https://pulseapi.blinq.pk/api/blinq/health";
  static const String dbHealth = '$siteUrl/database?environment=';
  static const String domainStatus = '$siteUrl/domainstatus?domainUrl=';
  static const  timer = 150;

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













}

