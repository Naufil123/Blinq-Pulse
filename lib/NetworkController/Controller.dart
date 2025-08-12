import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final Map<String, VoidCallback> _pageReloadCallbacks = {};

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results.isNotEmpty ? results.first : ConnectivityResult.none);
    });
  }


  void registerPageReloadCallback(String pageId, VoidCallback reloadCallback) {
    _pageReloadCallbacks[pageId] = reloadCallback;
  }

  void unregisterPageReloadCallback(String pageId) {
    _pageReloadCallbacks.remove(pageId);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) async {

    if (connectivityResult != ConnectivityResult.none) {
      final currentRoute = Get.currentRoute;
      if (_pageReloadCallbacks.containsKey(currentRoute)) {
        _pageReloadCallbacks[currentRoute]!();
      }

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      if (connectivityResult == ConnectivityResult.wifi) {
        final isInternetAvailable = await _checkInternetAvailability();
        if (!isInternetAvailable) {

          _showNoInternetMessage2();
        } else {

          Get.closeCurrentSnackbar();
        }
      } else if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.ethernet) {
        _checkInternetSpeed(connectivityResult);
      }

    }
    if   (connectivityResult == ConnectivityResult.none) {
      _showNoInternetMessage();
    }
    else{
      nulll();
    }
    // else{
    // _showNoInternetMessage();
    // }
  }



  Future<bool> _checkInternetAvailability() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
  void _showNoInternetMessage2() {
    Get.rawSnackbar(
      messageText: const Text(
        'There is no or Poor Internet Connection. Please Connect to a Stable Internet Connection or Try Again.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
        ),
      ),
      isDismissible: false,
      duration: const Duration(seconds: 7),
      backgroundColor: Colors.red,
      icon: const Icon(Icons.wifi_off, color: Colors.white, size: 30,),
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.GROUNDED,
    );
  }
  void _showNoInternetMessage() {
    Get.rawSnackbar(
      messageText: const Text(
        'There is no or Poor Internet Connection. Please Connect to a Stable Internet Connection or Try Again.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.5,
        ),
      ),
      isDismissible: false,
      duration: const Duration(days: 7),//days
      backgroundColor: Colors.red,
      icon: const Icon(Icons.wifi_off, color: Colors.white, size: 30,),
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.GROUNDED,
    );
  }
  void nulll(){
    print("hi");
  }
  Future<void> _checkInternetSpeed(ConnectivityResult connectivityResult) async {
    try {
      if (connectivityResult == ConnectivityResult.wifi) {
        final stopwatch = Stopwatch()..start();
        final response = await http.get(Uri.parse('https://www.google.com'), headers: {});
        stopwatch.stop();

        final speedInKbps = response.body.length * 8 / 1024 / (stopwatch.elapsedMilliseconds / 1000);
        if (kDebugMode) {
          print('Internet speed: $speedInKbps kbps');
        }

        if (speedInKbps <= 5 || speedInKbps == 0) {
          Get.rawSnackbar(
            messageText: const Text(
              'Your internet connection is too slow. Please try again later.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
              ),
            ),
            isDismissible: false,
            duration: const Duration(seconds: 7),
            backgroundColor: Colors.red[400]!,
            icon: const Icon(Icons.warning, color: Colors.white, size: 30,),
            margin: EdgeInsets.zero,
            snackStyle: SnackStyle.GROUNDED,
          );
        } else {
          // Close the banner if it's open
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
        }
      }
    } catch (e) {
      print('Error checking internet speed: $e');
    }
  }

}
